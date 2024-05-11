_package_bootstrap() {
	_${_INSTALL_INSTALLER}_bootstrap_is_${_INSTALL_INSTALLER}_available || {
		_${_INSTALL_INSTALLER}_bootstrap_platform
		_${_INSTALL_INSTALLER}_bootstrap_is_${_INSTALL_INSTALLER}_available || _PACKAGE_DISABLED=1
	}

	_${_INSTALL_INSTALLER}_bootstrap
}

_package_bootstrap_is_package_available() {
	_${_INSTALL_INSTALLER}_bootstrap_is_package_available
}

_package_install() {
	_package_enabled || {
		_warn "$_INSTALL_INSTALLER is disabled"
		return
	}

	local packages
	local package
	for package in "$@"; do
		_package_is_installed $package || {
			if [ -n "$packages" ]; then
				packages="$packages $package"
			else
				packages="$package"
			fi
		}
	done

	if [ -n "$packages" ]; then
		_${_INSTALL_INSTALLER}_install "$packages"
	fi
}

_package_update() {
	_package_enabled || {
		_warn "$_INSTALL_INSTALLER is disabled"
		return
	}

	[ -n "$_INSTALL_UPDATES_DISABLED" ] && {
		_warn "$_INSTALL_INSTALLER updates are disabled"
	}

	_info "Updating via ${_INSTALL_INSTALLER}"
	_${_INSTALL_INSTALLER}_update
}

_package_uninstall() {
	_package_enabled || {
		_warn "$_INSTALL_INSTALLER is disabled"
		return
	}

	_${_INSTALL_INSTALLER}_uninstall "$@"
}

_package_is_installed() {
	_${_INSTALL_INSTALLER}_is_installed "$@"
}

_package_is_file() {
	return 1
}

_package_enabled() {
	if [ -z "$_PACKAGE_DISABLED" ] || [ $_PACKAGE_DISABLED -eq 0 ]; then
		return 0
	fi

	return 1
}
