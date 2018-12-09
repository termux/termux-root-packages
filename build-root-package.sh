#!/bin/bash

set -e -o pipefail -u

# link into main package repo to handle dependencies
for root_package in packages/*; do
    ln -sf ../../${root_package} termux-packages/packages/
done

cd termux-packages
./build-package.sh "$@"
