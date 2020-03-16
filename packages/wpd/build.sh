TERMUX_PKG_HOMEPAGE=https://github.com/kbeflo/wpd
TERMUX_PKG_DESCRIPTION="Shows all WiFi networks and passwords stored on your phone"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="Kleo Bercero @kbeflo"
TERMUX_PKG_VERSION=1.0.0
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_extract_package() {
	local CHECKED_OUT_FOLDER=$TERMUX_PKG_CACHEDIR/wpd-checkout-$TERMUX_PKG_VERSION
	if [ ! -d $CHECKED_OUT_FOLDER ]; then
		local TMP_CHECKOUT=$TERMUX_PKG_TMPDIR/tmp-checkout
		rm -Rf $TMP_CHECKOUT
		mkdir -p $TMP_CHECKOUT

		git clone --depth 1 \
			--branch master \
			https://github.com/kbeflo/wpd.git \
			$TMP_CHECKOUT
		cd $TMP_CHECKOUT
		git fetch --all --tags --prune
		git checkout "tags/$TERMUX_PKG_VERSION" -b "$TERMUX_PKG_VERSION"
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