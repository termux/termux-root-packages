TERMUX_PKG_HOMEPAGE=https://sourceware.org/lvm2/
TERMUX_PKG_DESCRIPTION="A device-mapper library from LVM2 package"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=2.03.02
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/sourceware/lvm2/releases/LVM2.${TERMUX_PKG_VERSION}.tgz
TERMUX_PKG_SHA256=550ba750239fd75b7e52c9877565cabffef506bbf6d7f6f17b9700dee56c720f
TERMUX_PKG_DEPENDS="libandroid-support, libaio, readline"
TERMUX_PKG_BUILD_IN_SRC=yes
TERMUX_PKG_API_LEVEL=23

termux_step_make() {
	make -j"${TERMUX_MAKE_PROCESSES}" lib.device-mapper
}

termux_step_make_install() {
	cd libdm
	make install
}
