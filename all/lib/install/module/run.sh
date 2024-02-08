_run_install() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "run install" sh $1
}

_run_uninstall() {
	_warn "run uninstall - Not implemented"
}

_run_is_installed() {
	return 1
}

_run_is_file() {
	return 0
}
