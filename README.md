# Termux root packages
This repository is a work in progress to collect packages that are usable by root only.

# Building a package
To build a package, stand in the [termux-packages](https://github.com/termux/termux-packages) checkout and build with:

```sh
./build-package.sh path-to-termux-root-packages/packages/package-to-build
```

# Subscribing to the repository
To install packages from this repository you need to subscribe to it with:
```bash
pkg install root-repo
```

