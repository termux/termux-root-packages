#MDK is a proof-of-concept tool to exploit common IEEE 802.11 protocol weaknesses.
# MDK4 is a new version of MDK3.

#MDK4 is a Wi-Fi testing tool from E7mer of 360, ASPj of k2wrlz, it uses the osdep library from the aircrack-ng project to inject frames on several operating systems. Many parts of it have been contributed by the great aircrack-ng community: Antragon, moongray, Ace, Zero_Chaos, Hirte, thefkboss, ducttape, telek0miker, Le_Vert, sorbo, Andy Green, bahathir, Dawid Gajownik and Ruslan Nabioullin. THANK YOU!

#MDK4 is licenced under the GPLv2 or later.

TERMUX_PKG_MAINTAINER="KimoCoder & Ezmer "
TERMUX_PKG_HOMEPAGE=https://github.com/aircrack-ng/mdk4
TERMUX_PKG_DESCRIPTION="MDK is a proof-of-concept tool to exploit common IEEE 802.11 protocol weaknesses."
TERMUX_PKG_LICENSE="GPL-3.0"


TERMUX_PKG_VERSION=4.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/aircrack-ng/mdk4/archive/master.zip
TERMUX_PKG_SHA256=bd0ecaf82bef2b0b8880792ea7d88f08ae7161d17625cdd109ebf53be57e7b11
TERMUX_PKG_DEPENDS="pkg-config, libnl, libpcap"
TERMUX_PKG_BUILD_IN_SRC=true

