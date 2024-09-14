_conf() {
	local conf_replace

	[ $($_CONF_INSTALL_GNU_GREP -Pc '^[\s]*conf .*$' $1) -gt 1 ] && {
		$_CONF_INSTALL_GNU_GREP -P '^[\s]*conf .*$' $1
		_error "Only 1 conf declaration is allowed: $1"
	}

	conf_replace=$($_CONF_INSTALL_GNU_GREP -m 1 -Pohn '^[\s]*conf .*$' $1)
	[ -z "$conf_replace" ] && return 1

	local line_number=${conf_replace%%:*}
	local conf=${conf_replace#*:}
	conf=${conf#*conf }

	conf="$conf install $_TARGET_APPLICATION_NAME"

	file=$1 line_number=$line_number _conf_import $conf
	_insert_after $1 "_CONFIGURATIONS=\"$conf\"" $(_last_import_line $1)
}

_conf_import() {
	local feature_imports arg

	for arg in $@; do
		feature_imports="$feature_imports $arg/$_TARGET_PLATFORM/defaults/* $arg/all/defaults/*"
		_setup_git_import "git:$arg"

		case $file in
		*.feature/*)
			local arg_feature_all_defaults=$(printf '%s' "$file" | sed -e 's/^.*\/feature\//feature\//' -e 's/\.feature\/.*$/\.feature\/all\/defaults\/\*/')
			local arg_feature_platform_defaults=$(printf '%s' "$file" | sed -e 's/^.*\/feature\//feature\//' -e "s/\.feature\/.*$/\.feature\/$_TARGET_PLATFORM\/defaults\/\*/")
			feature_imports="$feature_imports $arg_feature_all_defaults $arg_feature_platform_defaults"
			;;
		esac
	done

	_import_file_contents $file $line_number $feature_imports
}
