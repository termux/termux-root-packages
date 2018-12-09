TERMUX_PKG_HOMEPAGE=https://wireless.wiki.kernel.org/en/users/documentation/iw
TERMUX_PKG_DESCRIPTION="CLI configuration utility for wireless devices"
TERMUX_PKG_VERSION=4.14
TERMUX_PKG_SRCURL=https://mirrors.edge.kernel.org/pub/software/network/iw/iw-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=f01671c0074bfdec082a884057edba1b9efd35c89eda554638496f03b769ad89
TERMUX_PKG_MAINTAINER="Auxilus @Auxilus"
TERMUX_PKG_DEPENDS="libnl, libnl-dev, pkg-config"
TERMUX_PKG_BUILD_IN_SRC=yes
