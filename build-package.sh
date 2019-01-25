#!/bin/bash

set -e -o pipefail -u

# link into main package repo to handle dependencies
for package in packages/*; do
    #TODO: handle docker image builds better
    ln -sf ../../${package} termux-packages/packages/
done

cd termux-packages
./build-package.sh "$@"
