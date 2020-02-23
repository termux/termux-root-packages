# Termux root packages

[![Powered by JFrog Bintray](./.github/static/powered-by-bintray.png)](https://bintray.com)

[![pipeline status](https://api.cirrus-ci.com/github/termux/termux-root-packages.svg)](https://api.cirrus-ci.com/github/termux/termux-root-packages.svg)

This repository contains packages that are only useful for rooted users.

# Contributing

Information on how to open pull requests to help keep the packages here up to date can be read in [CONTRIBUTING.md](CONTRIBUTING.md)

# Building a package

To build a package, first clone termux-root-packages,
```sh
git clone https://github.com/termux/termux-root-packages
```
and then update the termux-packages submodule.
```sh
cd termux-root-packages
git submodule init
git submodule update
```
You can then build a package with the following:
```sh
./build-package.sh name-of-package
```
Note that this currently only works outside of the docker container.
To build from the docker container, termux-root-packages has to be a subfolder of termux-packages, and a root package can then be built with
```sh
./build-package.sh termux-root-packages/packages/package-to-build
```
The termux-package submodule is not needed for this.

# Subscribing to the repository

To install packages from this repository, you need to subscribe to it with:
```sh
pkg install root-repo
```
