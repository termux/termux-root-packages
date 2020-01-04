TERMUX_PKG_HOMEPAGE=http://www.ex-parrot.com/~pdw/iftop/
TERMUX_PKG_DESCRIPTION="Display bandwidth usage on an interface"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=1.0pre4
TERMUX_PKG_SRCURL=http://www.ex-parrot.com/~pdw/iftop/download/iftop-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=f733eeea371a7577f8fe353d86dd88d16f5b2a2e702bd96f5ffb2c197d9b4f97
TERMUX_PKG_DEPENDS="c-ares, libpcap, ncurses"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--with-resolver=ares"

termux_step_pre_configure() {
	autoreconf -fi
}
