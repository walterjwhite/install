_uninstall() {
	_require "$_TARGET_APPLICATION_NAME" "_TARGET_APPLICATION_NAME must be set"
	_require "$_INSTALL_LIBRARY_PATH" "_INSTALL_LIBRARY_PATH must be set"

	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME ] && return 1
	[ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata ] && return 1

	_uninstall_script
	_uninstall_files
	_uninstall_type

	_sudo rm -Rf $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME

	_info "Uninstalled $_TARGET_APPLICATION_NAME"
}

_uninstall_script() {
	if [ -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/uninstall ]; then
		find $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/uninstall -type f -exec _sudo {} \;
	fi
}

_uninstall_files() {
	if [ -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files ]; then
		if [ "$_ROOT" = "/" ]; then
			_sudo rm -f $(cat $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files)
		else
			local sed_safe_root=$(_sed_safe $_ROOT)
			_sudo rm -f $(sed -e "s/^/$sed_safe_root/" $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files)
		fi

		_sudo rm -f $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files
	fi
}

_uninstall_type() {
	if [ ! -e $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type ]; then
		return 1
	fi

	for _SETUP_TYPE_FILE in $(find $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type -type f -name '.*'); do
		_SETUP_TYPE_NAME=$(basename $_SETUP_TYPE_FILE | sed -e 's/^.//')
		_uninstall_type_do
	done
}

_uninstall_type_do() {
	local packages=$($_CONF_INSTALL_GNU_GREP -Pv '(^$|^#)' $_SETUP_TYPE_FILE)

	if [ -z "$packages" ]; then
		_detail "No ${_SETUP_TYPE_NAME}(s) to uninstall"
		return
	fi

	_info "Uninstalling $packages via ${_SETUP_TYPE_NAME}"
	_${_SETUP_TYPE_NAME}_uninstall $packages
}
