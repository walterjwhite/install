_mas_install() {
	mas install "$@"
}

_mas_update() {
	mas upgrade
	mas update "$@"
}
