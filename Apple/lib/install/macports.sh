_macports_is_installed() {
	which port >/dev/null 2>&1
}

_macports_install() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "macports install - self update" port selfupdate
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "macports install" port install $@
}

_macports_update() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "macports update - self update" port selfupdate
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "macports update" port upgrade $@
}

_macports_bootstrap() {
	:
}
