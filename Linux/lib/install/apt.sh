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
	_sudo apt install -y $@
}

_apt_uninstall() {
	_sudo apt remove -y $@
}

_apt_update() {
	_sudo apt update -y
	_sudo apt upgrade -y
}

_apt_is_installed() {
	apt list --installed | grep "^$1/.* \[.*installed.*\]$"
}
