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
	_sudo yum install -y $@
}

_yum_uninstall() {
	_sudo yum remove -y $@
}

_yum_update() {
	_sudo yum update -y
	_sudo yum upgrade -y
}

_yum_is_installed() {
	yum list --installed | grep "^$1/.* [installed]$"
}
