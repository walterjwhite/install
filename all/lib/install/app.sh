import time.sh

_setup_project() {
	_clone

	_is_latest $_TARGET_APPLICATION_NAME && {
		if [ -z "$_INSTALL_FORCE" ]; then
			_warn "Latest version of app is already installed: $_TARGET_APPLICATION_NAME"
			return 1
		fi
	}

	_is_app

	_TARGET_PLATFORM=$_PLATFORM

	_application_settings
	_application_defaults $_TARGET_PLATFORM


	[ $_OPTN_INSTALL_BYPASS_UNINSTALL ] || _uninstall
	_prepare_target
	_bootstrap

	_metadata_write_app

	_install $_TARGET_PLATFORM

	_setup setup

	_features $_TARGET_PLATFORM/feature

	_setup post-setup

	_info "$_TARGET_APPLICATION_NAME - Completed installation"
}
