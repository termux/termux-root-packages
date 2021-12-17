TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libcdio
TERMUX_PKG_DESCRIPTION="This is a port of xiph.org's cdda paranoia to use libcdio for CDROM access."
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_LICENSE="GNU Public License 3.0"
TERMUX_PKG_VERSION=10.2+2.0.1
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/libcdio/libcdio-paranoia-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=28d7d00e4a83d0221acda0fd2eb3e3240bf094db4c00a85998922201939fa952
TERMUX_PKG_DEPENDS="libcdio"
TERMUX_INSTALL_DEPS=true
TERMUX_PKG_BUILD_IN_SRC=true
termux_step_configure() {
	${TERMUX_PKG_SRCDIR}/configure --prefix=${PREFIX} LDFLAGS=" -landroid-glob"
}
termux_step_make(){
	cd ${TERMUX_PKG_SRCDIR} && make -j8
}
termux_step_make_install() {
	cd ${TERMUX_PKG_SRCDIR} && make install
}

