_expect_install() {
	$1 >/dev/null 2>&1
}

_expect_uninstall() {
	_warn "expect uninstall - Not implemented"
}

_expect_is_installed() {
	return 1
}

_expect_is_file() {
	return 0
}
