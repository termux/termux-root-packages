TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libcdio
TERMUX_PKG_DESCRIPTION="This is a port of xiph.org's cdda paranoia to use libcdio for CDROM access."
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_VERSION=10.2+2.0.1
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/libcdio/libcdio-paranoia-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=28d7d00e4a83d0221acda0fd2eb3e3240bf094db4c00a85998922201939fa952
TERMUX_PKG_DEPENDS="libcdio, libandroid-glob"
termux_step_pre_configure() {
	LDFLAGS=" -landroid-glob"
}
