#!/bin/bash
##
##  Determine updated packages and build them.
##  Used with GitLab CI.
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
DEBS_DIR="$REPO_DIR/deb-packages"
cd "$REPO_DIR" || {
    echo "[!] Failed to cd into '$REPO_DIR'."
    exit 1
}

## Create directory where *.deb files will be placed.
if ! mkdir -p "$DEBS_DIR" > /dev/null 2>&1; then
    echo "[!] Failed to create directory '$DEBS_DIR'."
    exit 1
fi

## Set target architecture.
if [ $# -ge 1 ]; then
    TERMUX_ARCH="$1"
else
    TERMUX_ARCH="aarch64"
fi

## Verify that script is running under CI (GitLab).
if [ -z "${CI_COMMIT_BEFORE_SHA}" ]; then
    echo "[!] CI_COMMIT_BEFORE_SHA is not set !"
    exit 1
fi
if [ -z "${CI_COMMIT_SHA}" ]; then
    echo "[!] CI_COMMIT_SHA is not set !"
    exit 1
fi

## Check for updated files and determine if they are part of packages.
if [ "$CI_COMMIT_BEFORE_SHA" = "0000000000000000000000000000000000000000" ]; then
    UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "${CI_COMMIT_SHA}" | grep -P "packages/")
else
    UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r "${CI_COMMIT_BEFORE_SHA}..${CI_COMMIT_SHA}" | grep -P "packages/")
fi
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

echo "[@] Building packages for architecture '$TERMUX_ARCH':"
build_log="$DEBS_DIR/build-$TERMUX_ARCH.log"

for pkg in $PACKAGE_NAMES; do
    pkg=$(basename "$pkg")
    echo "[+]   Processing $pkg:"

    for dep_pkg in $(./scripts/buildorder.py "./packages/$pkg"); do
        dep_pkg=$(basename "$dep_pkg")
        echo -n "[+]     Compiling dependency $dep_pkg... "
        if ./build-package.sh -o "$DEBS_DIR" -a "$TERMUX_ARCH" -s "$dep_pkg" >> "$build_log" 2>&1; then
            echo "ok"
        else
            echo "fail"
            echo "[=] LAST 500 LINES OF BUILD LOG:"
            echo
            tail -n 500 "$build_log"
            echo
            exit 1
        fi
    done

    echo -n "[+]     Compiling $pkg... "
    if ./build-package.sh -f -o "$DEBS_DIR" -a "$TERMUX_ARCH" "$pkg" >> "$build_log" 2>&1; then
        echo "ok"
    else
        echo "fail"
        echo "[=] LAST 500 LINES OF BUILD LOG:"
        echo
        tail -n 500 "$build_log"
        echo
        exit 1
    fi

    echo "[+]   Successfully built $pkg."
done
echo "[@] Finished successfully."
