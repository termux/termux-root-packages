TERMUX_PKG_HOMEPAGE=https://github.com/royhills/arp-scan
TERMUX_PKG_DESCRIPTION="arp-scan is a command-line tool for system discovery and fingerprinting. It constructs and sends ARP requests to the specified IP addresses, and displays any responses that are received."
TERMUX_PKG_VERSION=1.9.5
TERMUX_PKG_SRCURL=https://github.com/royhills/arp-scan/archive/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=aa9498af84158a315b7e0ea6c2cddfa746660ca3987cbe7e32c0c90f5382d9d2
TERMUX_PKG_DEPENDS="libpcap" #make
TERMUX_PKG_BUILD_DEPENDS="libpcap-dev"

if [[ ${TERMUX_ARCH_BITS} == 32 ]]; then
    # Retrieved from compilation on device:
    TERMUX_PKG_EXTRA_CONFIGURE_ARGS+="pgac_cv_snprintf_long_long_int_format=%lld"
fi

termux_step_pre_configure () {
	aclocal
    	autoheader
	automake --add-missing
	autoconf
}
