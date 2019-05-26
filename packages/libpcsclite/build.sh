TERMUX_PKG_HOMEPAGE=https://pcsclite.apdu.fr/
TERMUX_PKG_DESCRIPTION="Middleware to access a smart card using SCard API (PC/SC)."
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_VERSION=1.8.25
TERMUX_PKG_SRCURL=https://pcsclite.apdu.fr/files/pcsc-lite-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=d76d79edc31cf76e782b9f697420d3defbcc91778c3c650658086a1b748e8792
TERMUX_PKG_DEPENDS="libusb"
TERMUX_PKG_DEVPACKAGE_DEPENDS="python2"
TERMUX_PKG_BUILD_DEPENDS="flex"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--exec-prefix=$TERMUX_PREFIX
--sbindir=$TERMUX_PREFIX/bin
--enable-ipcdir=$TERMUX_PREFIX/var/run
--disable-libsystemd
--disable-libudev"
TERMUX_PKG_INCLUDE_IN_DEVPACKAGE="bin/pcsc-spy share/man/man1/pcsc-spy.1.gz"

termux_step_pre_configure() {
	LDFLAGS+=" -llog"
}
