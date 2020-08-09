#!/bin/sh
##
##  Script for preparing & launching build environment.
##
##  Copyright 2019 Leonid Plyushch <leonid.plyushch@gmail.com>
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##

set -e -u

SCRIPT_NAME=$(basename "$0")
REPOROOT=$(dirname "$(realpath "$0")")

IMAGE_NAME="termux/package-builder"

LOCK_FILE="/tmp/.termux-root-builder.lck"
CONTAINER_NAME="termux-package-builder"
BUILD_ENVIRONMENT="termux-packages"

BUILDER_HOME="/home/builder"

cd "$REPOROOT"

if [ ! -e "$LOCK_FILE" ]; then
	touch "$LOCK_FILE"
fi

if [ "${GITHUB_EVENT_PATH-x}" != "x" ]; then
	# On CI/CD tty may not be available.
	DOCKER_TTY=""
else
	DOCKER_TTY=" --tty"
fi

(flock -n 3 || exit 0
	docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true

	echo "[*] Setting up repository submodules..."

	OWNER=$(stat -c "%U" "$REPOROOT")
	if [ "${OWNER}" != "$USER" ]; then
		sudo -u $OWNER git submodule deinit --all --force
		sudo -u $OWNER git submodule update --init
	else
		git submodule deinit --all --force
		git submodule update --init
	fi
) 3< "$LOCK_FILE"

(flock -n 3 || true
	echo "[*] Running container '$CONTAINER_NAME' from image '$IMAGE_NAME'..."
	if ! docker start "$CONTAINER_NAME" > /dev/null 2>&1; then
		echo "Creating new container..."
		docker run \
			--tty \
			--detach \
			--name "$CONTAINER_NAME" \
			--volume "${REPOROOT}/${BUILD_ENVIRONMENT}:${BUILDER_HOME}/termux-packages" \
			--workdir "${BUILDER_HOME}/termux-packages" \
			"$IMAGE_NAME"

		if [ "$(id -u)" -ne 0 ] && [ "$(id -u)" -ne 1000 ]; then
			echo "Changed builder uid/gid... (this may take a while)"
			docker exec $DOCKER_TTY "$CONTAINER_NAME" sudo chown -R $(id -u) "${BUILDER_HOME}"
			docker exec $DOCKER_TTY "$CONTAINER_NAME" sudo chown -R $(id -u) /data
			docker exec $DOCKER_TTY "$CONTAINER_NAME" sudo usermod -u $(id -u) builder
			docker exec $DOCKER_TTY "$CONTAINER_NAME" sudo groupmod -g $(id -g) builder
		fi
	fi

	echo "[*] Copying packages from './packages' to build environment..."
	for pkg in $(find "$REPOROOT"/packages -mindepth 1 -maxdepth 1 -type d); do
		PKG_DIR="${BUILDER_HOME}/${BUILD_ENVIRONMENT}/packages/$(basename "$pkg")"
		if docker exec "$CONTAINER_NAME" [ ! -d "${PKG_DIR}" ]; then
			# docker cp -a does not work, discussed here: https://github.com/moby/moby/issues/34142
			docker cp "$pkg" "$CONTAINER_NAME:${BUILDER_HOME}/${BUILD_ENVIRONMENT}"/packages/
		else
			echo "[!] Package '$(basename "$pkg")' already exists in build environment. Skipping."
		fi
	done

	if [ $# -ge 1 ]; then
		docker exec --interactive $DOCKER_TTY "$CONTAINER_NAME" "$@"
	else
		docker exec --interactive $DOCKER_TTY "$CONTAINER_NAME" bash
	fi
) 3< "$LOCK_FILE"
