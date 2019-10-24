#!/bin/bash

set -e -o pipefail -u

cd termux-packages
./build-package.sh "$@"
