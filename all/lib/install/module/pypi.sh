_pypi_bootstrap() {
	_pypi_bootstrap_is_pypi_available || {
		_pypi_bootstrap_platform
		_pypi_bootstrap_is_pypi_available || _PYPI_DISABLED=1
	}
}

_pypi_bootstrap_is_pypi_available() {
	which pip >/dev/null 2>&1
}

_pypi_install() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "pypi install" pip install -U --no-input "$@" >/dev/null
}

_pypi_uninstall() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "pypi uninstall" pip uninstall -y "$@" >/dev/null
}

_pypi_is_installed() {
	_error "PIP - is installed - NOT IMPLEMENTED"
}

_pypi_is_file() {
	return 1
}
