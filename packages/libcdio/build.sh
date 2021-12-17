TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libcdio
TERMUX_PKG_DESCRIPTION="The GNU Compact Disc Input and Control library (libcdio) contains a library for CD-ROM and CD image access. Applications wishing to be oblivious of the OS- and device-dependent properties of a CD-ROM or of the specific details of various CD-image formats may benefit from using this library."
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_LICENSE="GNU Public License 3.0"
TERMUX_PKG_VERSION=2.1.0
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/libcdio/libcdio-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=8550e9589dbd594bfac93b81ecf129b1dc9d0d51e90f9696f1b2f9b2af32712b
TERMUX_INSTALL_DEPS=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SUGGESTS="libcdio-paranoia, swig"
termux_step_configure() {
	${TERMUX_PKG_SRCDIR}/configure --prefix=${PREFIX} LDFLAGS=" -landroid-glob"
}
termux_step_make(){
	cd ${TERMUX_PKG_SRCDIR} && make -j8
}
termux_step_make_install() {
	cd ${TERMUX_PKG_SRCDIR} && make install
}
termux_step_post_make_install() {
	echo 'To install python bindings use  pip3 install pycdio (Requires swig to be installed)'
	echo 'To install perl bindings use  cpan Device::Cdio'
}
