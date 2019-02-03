#!/bin/bash
##
##  Determine updated packages and build them.
##  Used with Travis CI.
##
##  Leonid Plyushch <leonid.plyushch@gmail.com> (C) 2019
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
REPO_DIR=$(dirname "$SCRIPT_DIR")
cd "$REPO_DIR" || {
    echo "[!] Failed to cd into '$REPO_DIR'."
    exit 1
}

## Set target architecture.
if [ $# -ge 1 ]; then
    TERMUX_ARCH="$1"
else
    TERMUX_ARCH="aarch64"
fi

## Verify that script is running under CI (Travis).
if [ -z "${TRAVIS_COMMIT_RANGE}" ]; then
    echo "[!] TRAVIS_COMMIT_RANGE is not set !"
    exit 1
fi

## Check for updated files and determine if they are part of packages.
UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "${TRAVIS_COMMIT_RANGE//.../..}" | grep -P "packages/")
if [ -z "$UPDATED_FILES" ]; then
    echo "[*] No packages changed."
    echo "[*] Finishing with status 'OK'."
    exit 0
fi

## Determine package directories.
PACKAGE_DIRS=$(echo "$UPDATED_FILES" | grep -oP "packages/[a-z0-9+._-]+" | sort | uniq)
if [ -z "$PACKAGE_DIRS" ]; then
    echo "[*] No packages changed."
    echo "[*] Finishing with status 'OK'."
    exit 0
fi

## Filter directories to include only ones that actually exist.
existing_dirs=""
for dir in $PACKAGE_DIRS; do
    if [ -d "$REPO_DIR/$dir" ]; then
        existing_dirs+=" $dir"
    fi
done
PACKAGE_DIRS="$existing_dirs"
unset dir existing_dirs

## Determine package names.
PACKAGE_NAMES=$(echo "$PACKAGE_DIRS" | sed 's/packages\///g')
if [ -z "$PACKAGE_NAMES" ]; then
    echo "[!] Failed to determine package names."
    echo "    Perhaps, script failed ?"
    exit 1
fi

## Go to build environment.
if ! cd "$REPO_DIR/termux-packages" > /dev/null 2>&1; then
    echo "[!] Failed to cd into '$REPO_DIR/termux-packages'."
    exit 1
fi

## Print dot every 5 seconds so Travis CI won't kill
## our job.
timed_message() {
    local MESSAGE_DELAY=5

    while true; do
        sleep "${MESSAGE_DELAY}" && {
            if flock -n . true; then
                break
            fi
            echo -n "." > /dev/tty
        }
    done
}

# Setup docker.
echo "Creating new container..."
docker run \
    --detach \
    --env HOME=/home/builder \
    --name travis-ci-termux-build \
    --volume "$REPO_DIR/termux-packages:/home/builder/termux-packages" \
    --volume "$REPO_DIR/build-data:/data" \
    --tty \
    termux/package-builder

if [ $(id -u) -ne 1000 -a $(id -u) -ne 0 ]; then
    echo "Changed builder uid/gid... (this may take a while)"
    docker exec --tty travis-ci-termux-build chown -R $(id -u) /home/builder
    docker exec --tty travis-ci-termux-build chown -R $(id -u) /data
    docker exec --tty travis-ci-termux-build usermod -u $(id -u) builder
    docker exec --tty travis-ci-termux-build groupmod -g $(id -g) builder
    docker exec --tty travis-ci-termux-build bash /home/builder/termux-packages/setup-build-environment.sh > /dev/null
fi

build_log="$REPO_DIR/build-$TERMUX_ARCH.log"
rm -f "$build_log"

for pkg in $PACKAGE_NAMES; do
    echo -n "[@] Building $pkg."
    coproc timed_message

    flock . docker exec \
        --interactive \
        --tty \
        --user builder \
        travis-ci-termux-build \
        ./build-package.sh -f -a "$TERMUX_ARCH" "$pkg" >> "$build_log" 2>&1

    if [ $? != 0 ]; then
        echo "[!] Build failed."
        echo
        echo "LAST 500 LINES FROM BUILD LOG:"
        echo
        tail -n 500 "$build_log"
        exit 1
    fi

    wait
    echo
done
