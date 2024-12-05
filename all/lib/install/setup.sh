_setup() {
	if [ ! -e $_CONF_INSTALL_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$1 ]; then
		return 1
	fi

	_configure $_CONF_INSTALL_CONFIG_PATH/git
	_configure $_CONF_INSTALL_CONFIG_PATH/install

	if [ "$_TARGET_APPLICATION_NAME" != "install" ] && [ "$_TARGET_APPLICATION_NAME" != "git" ]; then
		_configure $_CONF_INSTALL_CONFIG_PATH/$_TARGET_APPLICATION_NAME
	fi

	_setup_run $1
}

_setup_run() {
	local setup_script
	for setup_script in $(find $_CONF_INSTALL_DATA_REGISTRY_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$1 -type f 2>/dev/null | sort -u); do
		_setup_run_script "$setup_script"
	done
}

_setup_run_script() {
	local setup_type_name=$(basename $1)

	_variable_is_set ${setup_type_name}_disabled && return

	if [ $(printf '%s' $setup_type_name | grep -c '.') -gt 0 ]; then
		setup_type_name=$(printf '%s' $setup_type_name | sed -e "s/^.*\.//")
	fi

	if [ -z "$setup_type_name" ] || [ "$setup_type_name" = "." ]; then
		_warn "setup_type_name is corrupt: $setup_type_name ($1)"
	fi

	if [ ! -e $1 ]; then
		_warn "$1 no longer exists, ignoring"
		return 0
	fi

	_sudo mkdir -p "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type"

	_setup_run_do_bootstrap $setup_type_name
	_${setup_type_name}_is_file
	if [ $? -eq 0 ]; then
		_WARN=$_CONF_INSTALL_FEATURE_TIMEOUT_ERROR_LEVEL _${setup_type_name}_install $1 || {
			local error=$?
			_warn "Error installing: $setup_type_name: $1"
			return $error
		}

		_call _${setup_type_name}_get_data $1 | _write "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type/.${setup_type_name}"
	else
		local packages=$($_CONF_INSTALL_GNU_GREP -Pv '(^$|^#)' $1 | tr '\n' ' ')

		_WARN=$_CONF_INSTALL_FEATURE_TIMEOUT_ERROR_LEVEL _${setup_type_name}_install $packages || {
			local error=$?
			_warn "Error installing $packages"
			return $error
		}

		printf "$packages" | tr ' ' '\n' | _write "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/type/.${setup_type_name}"
	fi

	_call _${setup_type_name}_cleanup

	return 0
}

_setup_run_do_bootstrap() {
	_setup_type_bootstrapped $1 || {
		_call _${1}_bootstrap

		export _BOOTSTRAP_${1}=1
		printf '_BOOTSTRAP_%s=1\n' "$1" | _install_metadata_write
	}
}

_setup_type_bootstrapped() {
	_variable_is_set _BOOTSTRAP_${1}
}
