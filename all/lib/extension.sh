_run_extensions() {
	[ $_PROVIDER_NAME ] || _PROVIDER_NAME=provider
	[ $extension_path ] || extension_path=$_CONF_INSTALL_APPLICATION_LIBRARY_PATH/$_PROVIDER_NAME
	[ ! -e $extension_path ] && return 1

	_increase_indent

	local application_name_prefix=$(printf '%s' $_APPLICATION_NAME | tr '-' '_' | tr '.' '_')

	for _EXTENSION in $(find $extension_path -type f | sort); do
		_EXTENSION_NAME=$(basename $_EXTENSION | sed -e 's/\.sh$//')

		_EXTENSION_FUNCTION_NAME=$(printf '%s' $_EXTENSION_NAME | tr '-' '_' | tr '.' '_')
		_EXTENSION_CLEAR_KEY=$(printf '%s' $_EXTENSION_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_' | tr '.' '_')

		_add_logging_context $_EXTENSION_NAME

		_call _${application_name_prefix}_before_each

		. $_EXTENSION

		if [ "$#" -eq 0 ]; then
			_${application_name_prefix}_${_EXTENSION_FUNCTION_NAME}${_EXTENSION_FUNCTION_SUFFIX}
		else
			[ -n "$1" ] && $1
			[ -n "$2" ] && $2
		fi

		_call _${application_name_prefix}_after_each

		_remove_logging_context
		unset _EXTENSION_NAME _EXTENSION_FUNCTION_NAME _EXTENSION_CLEAR_KEY
	done

	_decrease_indent
}

_load_extension() {
	if [ $# -lt 1 ]; then
		_error "Extension name is required, ie. firefox"
	fi

	local extension_name=$1
	shift

	[ $extension_path ] || extension_path=$_CONF_INSTALL_APPLICATION_LIBRARY_PATH/$_PROVIDER_NAME

	local extension_file=$(find $extension_path -type f -name "$extension_name.sh" | head -1)
	_optional_include $extension_file || _error "Unable to load $plugin_name"
}
