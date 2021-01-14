TERMUX_PKG_HOMEPAGE=https://containerd.io/
TERMUX_PKG_DESCRIPTION="An open and reliable container runtime"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.4.3
TERMUX_PKG_SRCURL=https://github.com/containerd/containerd/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=bc6d9452c700af0ebc09c0da8ddba55be4c03ac8928e72ca92d98905800c8018
TERMUX_PKG_DEPENDS="runc"

termux_step_make() {
	# setup go build environment
	termux_setup_golang
	export GOPATH="${PWD}/go"
	mkdir -p "${GOPATH}/src/github.com/containerd"
	ln -sf "${TERMUX_PKG_SRCDIR}" "${GOPATH}/src/github.com/containerd/containerd"
	cd "${GOPATH}/src/github.com/containerd/containerd"

	# apply some patches in a batch
	xargs sed -i "s_\(/etc/containerd\)_${TERMUX_PREFIX}\1_g" < <(grep -R /etc/containerd | cut -d':' -f1 | sort | uniq)

	# issue the build command
	export BUILDTAGS=no_btrfs
	make -j ${TERMUX_MAKE_PROCESSES}
	make -j ${TERMUX_MAKE_PROCESSES} man
}

termux_step_make_install() {
	DESTDIR=${TERMUX_PREFIX} make install
	DESTDIR=${TERMUX_PREFIX}/share make install-man
	install -Dm 600 ${TERMUX_PKG_BUILDER_DIR}/config.toml ${TERMUX_PREFIX}/etc/containerd/config.toml
}
