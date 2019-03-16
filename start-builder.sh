#!/bin/sh
set -e -u

REPOROOT=$(dirname "$(realpath "$0")")
LOCKFILE="/tmp/.termux-builder.lck"

IMAGE_NAME=termux/package-builder
: ${CONTAINER_NAME:=termux-package-builder}

cd "$REPOROOT"

if [ ! -e "$LOCKFILE" ]; then
	touch "$LOCKFILE"
fi

if [ ! -e "$REPOROOT/termux-packages/build-package.sh" ]; then
	echo "[*] Setting up repository submodules..."
	git submodule update --init
else
	(flock -n 3 || exit 0
		(cd "$REPOROOT"/termux-packages && git clean -fdxq && git checkout -- .)

		echo "[*] Copying packages from './packages' to build environment..."
		for pkg in "$REPOROOT"/packages/*; do
			if [ -d "$REPOROOT/termux-packages/packages/$(basename "$pkg")" ]; then
				echo "[*] Replacing existing $pkg in termux-packages..."
				rm -rf "$REPOROOT/termux-packages/packages/$pkg"
			fi
			cp -a "$pkg" "$REPOROOT"/termux-packages/packages/
		done
	) 3< "$LOCKFILE"
fi

(flock -n 3 || true
	echo "[*] Running container '$CONTAINER_NAME' from image '$IMAGE_NAME'..."
	if ! docker start "$CONTAINER_NAME" > /dev/null 2>&1; then
		echo "Creating new container..."
		docker run \
			--detach \
			--name "$CONTAINER_NAME" \
			--volume "$REPOROOT/termux-packages:/home/builder/termux-packages" \
			--tty \
			"$IMAGE_NAME"

		if [ "$(id -u)" -ne 0 ] && [ "$(id -u)" -ne 1000 ]; then
			echo "Changed builder uid/gid... (this may take a while)"
			docker exec --tty "$CONTAINER_NAME" sudo chown -R $(id -u) "/home/builder"
			docker exec --tty "$CONTAINER_NAME" sudo chown -R $(id -u) /data
			docker exec --tty "$CONTAINER_NAME" sudo usermod -u $(id -u) builder
			docker exec --tty "$CONTAINER_NAME" sudo groupmod -g $(id -g) builder
		fi

		# echo "[*] Installing dependencies in $CONTAINER_NAME..."
		# DEPENDENCIES=""
		# docker exec --tty "$CONTAINER_NAME" sudo apt update
		# docker exec --tty "$CONTAINER_NAME" sudo apt install $DEPENDENCIES
	fi

	if [ $# -ge 1 ]; then
		docker exec --interactive --tty "$CONTAINER_NAME" "$@"
	else
	        docker exec --interactive --tty "$CONTAINER_NAME" bash
	fi
) 3< "$LOCKFILE"
