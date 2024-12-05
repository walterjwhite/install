_rust_bootstrap() {
	_rust_bootstrap_is_rust_available || {
		_rust_bootstrap_platform
		_rust_bootstrap_is_rust_available || _RUST_DISABLED=1
	}
}

_rust_bootstrap_is_rust_available() {
	which cargo >/dev/null 2>&1
}

_rust_install() {
	_sudo cargo install "$@"
}

_rust_update() {
	_sudo cargo update "$@"
}

_rust_uninstall() {
	_sudo cargo uninstall "$@"
}

_rust_is_installed() {
	_error "RUST - is installed - NOT IMPLEMENTED"
}

_rust_is_file() {
	return 1
}
