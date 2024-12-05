_app_build() {
	_APP_INSTALLATION=0

	if [ ! -e .app ]; then
		_app_build_recursive
		return
	fi

	_app_build_instance
}

_app_build_recursive() {
	local app
	for app in $(find . -maxdepth 2 -type f -name .app | sed -e 's/\.app$//'); do
		cd $app
		_app_build_instance
		cd ..
	done
}

_app_build_instance() {
	_TARGET_APPLICATION_NAME=$(basename $PWD)

	_is_app

	_info "Building $_TARGET_APPLICATION_NAME"

	_settings_init
	_application_settings
	_app_build_all_platforms
}

_app_build_all_platforms() {
	SED_SAFE_PWD=$(_sed_safe $PWD)

	rm -rf $_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME && mkdir -p $_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME
	date >>$_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/.build-date

	if [ -e supported-platforms ]; then
		_app_build_platforms $(cat supported-platforms)
	else
		_app_build_platforms $(cat $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/.platforms)
	fi
}

_app_build_platforms() {
	for _TARGET_PLATFORM in $@; do
		_app_build_files

	done
}

_app_build_files() {
	if [ -n "$_INSTALL_BIN_FILE" ]; then
		_app_build_file $_INSTALL_BIN_FILE
		return
	fi

	for f in $(find . -type f ! -path '*/.*/*' ! -path '*/*.secret/*' ! -name '*.secret' \( -path '*/all/bin/*' -or -path "*/$_TARGET_PLATFORM/bin/*" -or -path '*/all/setup/*' -or -path "*/$_TARGET_PLATFORM/setup/*" -or -path '*/all/post-setup/*' -or -path "*/$_TARGET_PLATFORM/post-setup/*" -or -path '*/all/files/*' -or -path "*/$_TARGET_PLATFORM/files/*" -or -path '*/all/help/*' -or -path "*/$_TARGET_PLATFORM/help/*" -or -path "*/all/defaults/*" -or -path "*/$_TARGET_PLATFORM/defaults/*" \) | sort -r); do
		_app_build_file $f
	done
}

_app_build_file() {
	_debug "Building $1 -> $_TARGET_PLATFORM [$_PLATFORM]"

	file_relative=$(printf '%s\n' "$1" | sed -e "s/^$SED_SAFE_PWD\///" -e "s/$_TARGET_PLATFORM\///" -e 's/\/all\//\//')
	_OUTPUT_FILE=$_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/$_TARGET_PLATFORM/$file_relative

	mkdir -p $(dirname $_OUTPUT_FILE)
	cat $1 >>$_OUTPUT_FILE

	case $1 in
	*run | */bin/*)
		_inject $_OUTPUT_FILE
		;;
	esac

	local permissions=$(stat $_CONF_INSTALL_STAT_ARGUMENTS $1)
	chmod $permissions $_OUTPUT_FILE $1

	_imports $_OUTPUT_FILE
	_conf $_OUTPUT_FILE

	_update_remove_commented_code $_OUTPUT_FILE
	_update_constants $_OUTPUT_FILE
	_app_is_shell_script $_OUTPUT_FILE && shfmt -w $_OUTPUT_FILE

	_debug "Built $1 -> [$_TARGET_PLATFORM] [$_PLATFORM]"
}
