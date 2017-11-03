# Termux root packages
This repository is a work in progress to collect packages that are usable by root only.

# Building a package
To build a package, stand in the [termux-packages](https://github.com/termux/termux-packages) checkout and build with:

```sh
./build-package.sh path-to-termux-root-packages/packages/package-to-build
```

# Trying out a package
For now you have to install the deb file manually. In short we will create a separate APT repo that root users can enable to install these packages.
