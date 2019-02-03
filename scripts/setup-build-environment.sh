#!/bin/bash
##
##  Script for setting up build environment.
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

set -e

if [ "$(id -u)" != "0" ]; then
    echo
    echo "Without root, this script won't be able to install needed software."
    echo
    exit 1
fi

## Log to stdout by default
[ -z "${SETUP_LOG_FILE}" ] && SETUP_LOG_FILE=/proc/self/fd/1

PACKAGES=""

echo "[*] Updating system software..."
apt update --quiet >> "${SETUP_LOG_FILE}" 2>&1
apt upgrade --yes --quiet >> "${SETUP_LOG_FILE}" 2>&1

echo "[*] Installing additional software..."
# apt install --yes --quiet ${PACKAGES} >> "${SETUP_LOG_FILE}" 2>&1
