TERMUX_PKG_HOMEPAGE=https://github.com/kbeflo/wpd
TERMUX_PKG_DESCRIPTION="Shows all WiFi networks and passwords stored on your phone for Android Oreo+ (Root)"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Kleo Bercero @kbeflo"
TERMUX_PKG_VERSION=1.3.2
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_SRCURL=https://github.com/kbeflo/wpd/archive/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=37ce0707cbe46acb532d8b07fa958f160675c6e3250360a8c40413b9216e2eaf

termux_step_extract_package() {
	if [ ! -d $CHECKED_OUT_FOLDER ]; then
		local TMP_CHECKOUT=$TERMUX_PKG_TMPDIR/tmp-checkout
		rm -Rf $TMP_CHECKOUT
		mkdir -p $TMP_CHECKOUT

		cd $TMP_CHECKOUT
		tar -xf ${TERMUX_PKG_VERSION}.tar.gz wpd
		mv $TMP_CHECKOUT $CHECKED_OUT_FOLDER
	fi

	mkdir $TERMUX_PKG_SRCDIR
	cd $TERMUX_PKG_SRCDIR
	cp -Rf $CHECKED_OUT_FOLDER/* .
}

termux_step_make_install() {
	cp wpd $TERMUX_PREFIX/bin/wpd
	chmod +x $TERMUX_PREFIX/bin/wpd
}
