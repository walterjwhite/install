_bootstrap() {
	[ "$_APPLICATION_NAME" = "$_TARGET_APPLICATION_NAME" ] && _metadata_write_platform

	[ -z "$_PLATFORM_PACKAGES" ] && return 1
	[ -n "$_BOOTSTRAP_PLATFORM_PACKAGES_INSTALLED" ] && return 2

	_info "Installing pre-requisites"

	_setup_run_do_bootstrap package
	_package_install $_PLATFORM_PACKAGES

	_BOOTSTRAP_PLATFORM_PACKAGES_INSTALLED=1

	_metadata_write_platform
}

_npm_bootstrap_platform() {
	_package_install $_NPM_PACKAGE
}

_rust_bootstrap_platform() {
	_package_install $_RUST_PACKAGE
}

_pypi_bootstrap_platform() {
	_package_install $_PYPI_PACKAGE
}

_go_bootstrap_platform() {
	_package_install $_GO_PACKAGE
}
