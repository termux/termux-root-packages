TERMUX_PKG_HOMEPAGE=http://bluez.org
TERMUX_PKG_DESCRIPTION="Official Linux Bluetooth protocol stack"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=5.55
TERMUX_PKG_SRCURL=https://www.kernel.org/pub/linux/bluetooth/bluez-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=8863717113c4897e2ad3271fc808ea245319e6fd95eed2e934fae8e0894e9b88
TERMUX_PKG_DEPENDS="dbus, glib, json-c, libical, libsbc"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-udev
--disable-systemd
"

termux_step_post_get_source() {
	cp $TERMUX_PKG_BUILDER_DIR/{wordexp.c,wordexp.h} $TERMUX_PKG_SRCDIR/tools/
}
