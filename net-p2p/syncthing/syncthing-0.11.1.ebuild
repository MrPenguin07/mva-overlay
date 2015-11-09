# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils base systemd git-r3

DESCRIPTION="Open, trustworthy and decentralized syncing engine (some kind of analog of DropBox and BTSync)"
HOMEPAGE="http://syncthing.net"

SRC_URI=""
EGIT_REPO_URI="https://github.com/syncthing/${PN}"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
# No ~x86 keyword on godep in the tree
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-lang/go
	dev-go/godep
"
RDEPEND="${DEPEND}"

DOCS=( README.md AUTHORS LICENSE CONTRIBUTING.md )

export GOPATH="${S}"

GO_PN="github.com/syncthing/${PN}"
EGIT_CHECKOUT_DIR="${S}/src/${GO_PN}"
S="${EGIT_CHECKOUT_DIR}"

src_compile() {
	# XXX: All the stuff below needs for "-version" command to show actual info
	local version="$(git describe --always | sed 's/\([v\.0-9]*\)\(-\(beta\|alpha\)[0-9]*\)\?-/\1\2+/')";
	local date="$(git show -s --format=%ct)";
	local user="$(whoami)"
	local host="$(hostname)"; host="${host%%.*}";
	local lf="-w -X main.Version ${version} -X main.BuildStamp ${date} -X main.BuildUser ${user} -X main.BuildHost ${host}"

	godep go build -ldflags "${lf}" -tags noupgrade ./cmd/syncthing
}

src_install() {
	dobin syncthing
	systemd_dounit "${S}/etc/linux-systemd/system/${PN}@.service"
	systemd_douserunit "${S}/etc/linux-systemd/user/${PN}.service"
	base_src_install_docs
}
