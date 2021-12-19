TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libcdio
TERMUX_PKG_DESCRIPTION="Compact Disc Input and Control library"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_VERSION=2.1.0
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/libcdio/libcdio-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=8550e9589dbd594bfac93b81ecf129b1dc9d0d51e90f9696f1b2f9b2af32712b
TERMUX_INSTALL_DEPS=true
TERMUX_PKG_DEPENDS="libandroid-glob"
TERMUX_PKG_SUGGESTS="libcdio-paranoia, swig"
termux_step_pre_configure() {
	LDFLAGS=" -landroid-glob"
}
termux_step_create_debscripts() {
	echo "#!$TERMUX_PREFIX/bin/sh" >> postinst
	echo "echo To install python bindings use pip3 install pycdio (Requires swig to be installed)" >> postinst
	echo "echo To install perl bindings use cpan Device::Cdio" >> postinst
}
