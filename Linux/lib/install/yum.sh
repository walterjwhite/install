_yum_bootstrap() {
	:
}

_yum_bootstrap_platform() {
	:
}

_yum_bootstrap_is_yum_available() {
	which apt >/dev/null 2>&1
}

_yum_install() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "yum install" yum install -y $@
}

_yum_uninstall() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "yum uninstall" yum remove -y $@
}

_yum_update() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "yum update" yum update -y
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "yum update (upgrade)" yum upgrade -y
}

_yum_is_installed() {
	yum list --installed | grep "^$1/.* [installed]$"
}
