TERMUX_PKG_HOMEPAGE=https://fping.org
TERMUX_PKG_DESCRIPTION="Utility to ping multiple hosts at once"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="COPYING"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=4.2
TERMUX_PKG_SRCURL=https://github.com/schweikert/fping/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=49b0ac77fd67c1ed45c9587ffab0737a3bebcfa5968174329f418732dbf655d4

termux_step_pre_configure() {
	./autogen.sh
}
