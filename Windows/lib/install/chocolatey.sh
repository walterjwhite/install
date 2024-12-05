_chocolatey_install() {
	_chocolatey_run install $@
}

_chocolatey_update() {
	_chocolatey_run update $@
}

_chocolatey_is_disabled() {
	if [ -n _CHOCOLATEY_DISABLED ]; then
		return 0
	fi

	return 1
}

_chocolatey_run() {
	_chocolatey_is_disabled && return

	choco $1 $2

	local _install_status=$?
	if [ $_install_status -gt 0 ]; then
		_warn "Disabling chocolatey installer: $_install_status"
	fi
}

_chocolatey_bootstrap() {
	_error "Chocolatey bootstrap is not yet implemented"
}

_chocolatey_is_installed() {
	which choco >/dev/null 2>&1
}
