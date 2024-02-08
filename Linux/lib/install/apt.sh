_apt_bootstrap() {
	:
}

_apt_bootstrap_platform() {
	:
}

_apt_bootstrap_is_apt_available() {
	which apt >/dev/null 2>&1
}

_apt_install() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "Apt install" apt install -y $@
}

_apt_uninstall() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "Apt uninstall" apt remove -y $@
}

_apt_update() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "Apt update" apt update -y
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "Apt update (upgrade)" apt upgrade -y
}

_apt_is_installed() {
	apt list --installed | grep "^$1/.* \[.*installed.*\]$"
}
