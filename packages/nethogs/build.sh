TERMUX_PKG_HOMEPAGE=https://github.com/raboof/nethogs
TERMUX_PKG_DESCRIPTION="Net top tool grouping bandwidth per process"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="Pierre Rudloff <contact@rudloff.pro>"
TERMUX_PKG_VERSION=0.8.5-git
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/raboof/nethogs/archive/68033bfae63188a2189d752eec4bb9ac44503ecc.tar.gz
TERMUX_PKG_SHA256=a8751318e4472c4aad7e66763e65ab41cf62b88e3cee43ebaf990668055557d5
TERMUX_PKG_FOLDERNAME=nethogs-${TERMUX_PKG_VERSION}
TERMUX_PKG_DEPENDS="libc++, ncurses, libpcap"
TERMUX_PKG_EXTRA_MAKE_ARGS="nethogs"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure () {
	export CPPFLAGS="$CPPFLAGS -Wno-c++11-narrowing"
}
