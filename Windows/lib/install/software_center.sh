_software_center_install() {
	_software_center_run install $@
}

_software_center_update() {
	_software_center_run update $@
}

_software_center_is_disabled() {
	if [ -n _software_center_DISABLED ]; then
		return 0
	fi

	return 1
}

_software_center_run() {
	_software_center_is_disabled && return

	scclient.exe $1 $2

	local _install_status=$?
	if [ $_install_status -gt 0 ]; then
		_warn "Disabling software center installer: $_install_status"
	fi
}

_software_center_bootstrap() {
	_error "software center bootstrap is not yet implemented"
}

_software_center_is_installed() {
	which scclient.exe >/dev/null 2>&1
}
