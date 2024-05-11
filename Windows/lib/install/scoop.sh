_scoop_install() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "scoop install" scoop install $@
}

_scoop_update() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "scoop update" scoop update $@
}

_scoop_bootstrap() {
	_error "Scoop bootstrap is not yet implemented"
}

_scoop_is_installed() {
	which scoop >/dev/null 2>&1
}
