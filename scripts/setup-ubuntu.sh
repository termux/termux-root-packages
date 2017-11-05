#!/bin/bash
set -e -u

PACKAGES=""
PACKAGES+=" ant" # Used by apksigner.
PACKAGES+=" asciidoc"
PACKAGES+=" automake"
PACKAGES+=" bison"
PACKAGES+=" clang" # Used by golang, useful to have same compiler building.
PACKAGES+=" curl" # Used for fetching sources.
PACKAGES+=" ed" # Used by bc
PACKAGES+=" flex"
PACKAGES+=" g++-multilib" # For building nodejs-current mkpeephole for 32-bit arm and i686.
PACKAGES+=" gettext" # Provides 'msgfmt' which the apt build uses.
PACKAGES+=" git" # Used by the neovim build.
PACKAGES+=" gperf" # Used by the fontconfig build.
PACKAGES+=" help2man"
PACKAGES+=" intltool" # Used by qalc build.
PACKAGES+=" libglib2.0-dev" # Provides 'glib-genmarshal' which the glib build uses.
PACKAGES+=" libgnutls28-dev" # Needed by native build step of mariadb.
PACKAGES+=" libtool-bin"
PACKAGES+=" libncurses5-dev" # Used by mariadb for host build part.
PACKAGES+=" lzip"
PACKAGES+=" python3.6"
PACKAGES+=" tar"
PACKAGES+=" unzip"
PACKAGES+=" m4"
PACKAGES+=" openjdk-8-jdk-headless" # Used for android-sdk.
PACKAGES+=" pkg-config"
PACKAGES+=" python3-docutils" # For rst2man, used by mpv.
PACKAGES+=" python3-setuptools" # Needed by at least asciinema.
PACKAGES+=" python3-sphinx" # Needed by notmuch man page generation.
PACKAGES+=" scons"
PACKAGES+=" texinfo"
PACKAGES+=" xmlto"
PACKAGES+=" xutils-dev" # Provides 'makedepend' which the openssl build uses.
PACKAGES+=" libexpat1-dev" # Needed by ghostscript
PACKAGES+=" libjpeg-dev" # Needed by ghostscript

DEBIAN_FRONTEND=noninteractive sudo apt-get install -yq $PACKAGES

sudo mkdir -p /data/data/com.termux/files/usr
sudo chown -R `whoami` /data
