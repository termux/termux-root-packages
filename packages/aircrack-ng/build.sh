TERMUX_PKG_HOMEPAGE=https://www.aircrack-ng.org
TERMUX_PKG_DESCRIPTION="WiFi security auditing tools suite"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=1.6
TERMUX_PKG_SRCURL=https://download.aircrack-ng.org/aircrack-ng-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=4f0bfd486efc6ea7229f7fbc54340ff8b2094a0d73e9f617e0a39f878999a247
TERMUX_PKG_DEPENDS="libnl, openssl, libpcap, pciutils"
# clang can't handle ternary instrutions on aarch64:
# https://github.com/aircrack-ng/aircrack-ng/issues/1957
TERMUX_PKG_BLACKLISTED_ARCHES="aarch64"
