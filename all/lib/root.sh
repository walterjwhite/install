_require_root() {
	[ $(whoami) != "root" ] && _error "Please re-run $0 as root"
}
