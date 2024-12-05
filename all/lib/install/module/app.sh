_app_install() {
	_DEPENDENCY=1 app-install $1
}

_app_uninstall() {
	app-uninstall $1
}

_app_is_installed() {
	[ -e $_CONF_INSTALL_LIBRARY_PATH/.metadata ] && return 0

	return 1
}

_app_is_file() {
	return 1
}
