#!/bin/sh
# clean.sh - clean everything.
set -e -u

# Read settings from .termuxrc if existing
test -f $HOME/.termuxrc && . $HOME/.termuxrc
: ${TERMUX_TOPDIR:="$HOME/.termux-build"}

rm -Rf /data/* $TERMUX_TOPDIR
