_app_default_bootstrap() {
	:
}

_app_default_install() {
	if [ -n $_USER ]; then
		_SUDO_OPTIONS="-u $USER" _sudo xdg-mime default $1.desktop $2
		return $?
	fi

	xdg-mime default $1.desktop $2
}

_app_default_uninstall() {
	:
}

_app_default_is_installed() {
	:
}

_app_default_enabled() {
	return 0
}
