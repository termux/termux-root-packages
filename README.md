# Termux root packages
This repository is a work in progress to collect packages that are usable by root only.

# Building a package
To build a package, stand in the [termux-packages](https://github.com/termux/termux-packages) checkout and build with:

```sh
./build-package.sh path-to-termux-root-packages/packages/package-to-build
```

# Subscribing to the repository
To install packages from this repository you need to subscribe to it. 
Run these steps on your termux device:
```bash
# Needed by apt-key:
pkg install dirmngr
# Download key from keyserver:
apt-key adv --keyserver pgp.mit.edu --recv 9B4E7D27395024EA5A4FC6395AAAC9E0A46BE53C
mkdir -p $PREFIX/etc/apt/sources.list.d
# Setup repo:
echo "deb https://grimler.se root stable" > $PREFIX/etc/apt/sources.list.d/termux-root.list
apt update
```

