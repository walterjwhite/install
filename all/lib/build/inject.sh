_inject() {
	_setup_git_import "git:install"
	_inject_install_platform_init $1 init

	_inject_contents $1 "_configure \$_CONF_INSTALL_LIBRARY_PATH/\$_APPLICATION_NAME/.metadata"

	_inject_install_platform $1 lib/runtime

	_inject_app_defaults $1
	[ "$_TARGET_APPLICATION_NAME" != "install" ] && _inject_install_platform $1 defaults

	_inject_contents $1 "_APPLICATION_NAME='$_TARGET_APPLICATION_NAME'"
	_inject_contents $1 "set -a"

	_inject_required_configuration $1
}

_inject_install_platform() {

	local _platform_file
	for _platform_file in $(find $_GIT_IMPORT_PATH/all/$2 $_GIT_IMPORT_PATH/$_TARGET_PLATFORM/$2 -type f 2>/dev/null | sort -r); do
		_import_file_contents_all "$1" "$_platform_file"
	done
}

_inject_required_configuration() {
	local app_conf_name=$(printf '_CONF_%s_' ${_TARGET_APPLICATION_NAME} | tr '[:lower:]' '[:upper:]')

	local _defaults=$($_CONF_INSTALL_GNU_GREP -P ": \\$\{{0,1}$app_conf_name[\w]+:=.*\}" $1 | $_CONF_INSTALL_GNU_GREP -Po "$app_conf_name[\w]+" | sort -u | tr '\n' '|' | sed -e 's/|$//')

	_REQUIRED_APP_CONF=$($_CONF_INSTALL_GNU_GREP -Po "$app_conf_name[\w]+" $1 | $_CONF_INSTALL_GNU_GREP -Pv "($_defaults)")
	if [ -z "$_REQUIRED_APP_CONF" ]; then
		return 1
	fi

	_insert_after $1 "_REQUIRED_APP_CONF='$_REQUIRED_APP_CONF'" $(_last_import_line $1)
}

_inject_app_defaults() {
	local _feature_dir=$(printf '%s' "$1" | grep \.feature | sed -e 's/\.feature.*/.feature/')
	if [ -n "$_feature_dir" ]; then
		local feature_path=$(printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Po '^.*\.feature')
		local feature_name=$(printf '%s' "$feature_path" | sed -e 's/\.feature/\n/g' | sed -e 's/^.*\///' | grep -v '^$' | tr '\n' '/' | sed -e 's/\/$//')

		local feature_relative_path=feature/${feature_path#*/feature/}

		_debug "Injecting feature-specific defaults into feature - $feature_name ($feature_path)"
		for _platform_file in $(find $feature_relative_path/all/defaults $feature_relative_path/$_TARGET_PLATFORM/defaults -type f 2>/dev/null | sort -r); do
			_configure "$_platform_file"
			_import_file_contents_all "$1" "$_platform_file"
		done
	fi

	_debug "Injecting defaults into $1"
	local _default_file
	for _default_file in $(find all/defaults ${_TARGET_PLATFORM}/defaults -type f 2>/dev/null | sort -r); do
		_import_file_contents_all "$1" "$_default_file"
	done
}

_inject_contents() {
	$_CONF_INSTALL_GNU_SED -i "1 a $2" $1

	printf '\n' >>$1
}

_inject_install_platform_init() {
	local _platform_file
	for _platform_file in $(find $_GIT_IMPORT_PATH/all/$2 $_GIT_IMPORT_PATH/${_TARGET_PLATFORM}/$2 -type f 2>/dev/null | sort -r); do
		_insert_after $1 $_platform_file $(_last_import_line $1)
	done
}
