_imports() {
	while [ 1 ]; do
		update_count=0

		local update_pattern_match=$($_CONF_INSTALL_GNU_GREP -m 1 -Pohn '^[\s]*import .*$' $1 | head -1)
		if [ -z "$update_pattern_match" ]; then
			break
		fi

		local line_number=${update_pattern_match%%:*}
		local update_pattern=${update_pattern_match#*:}
		update_pattern=${update_pattern#*import }

		update_pattern=$(printf "$update_pattern" | sed -e "s/{{_PLATFORM_}}/\*$_TARGET_PLATFORM\*/")

		_import $1 $line_number "$update_pattern"
	done
}

_import() {
	if [ $(printf "$3" | grep -c '^git:') -gt 0 ]; then
		_setup_git_import "$3"

		local target_file=$_GIT_IMPORT_PATH/$_GIT_IMPORT_REF
		case $target_file in
		*.feature/*)
			local feature_all_import=$(printf '%s' "$target_file" | sed -e 's/\.feature/.feature\/all\/lib/')
			local feature_platform_import=$(printf '%s' "$target_file" | sed -e "s/\.feature/.feature\/$_TARGET_PLATFORM\/lib/")

			_import_file_contents $1 $2 $feature_platform_import $feature_all_import
			;;
		*)
			local platform_target_file=$(printf '%s' "$target_file" | sed -e "s/\/all\//\/$_TARGET_PLATFORM\//")
			_import_file_contents $1 $2 $target_file $platform_target_file
			;;
		esac

		return
	fi

	case $3 in
	*.feature/*)
		local feature_all_import=$(printf '%s' "$3" | sed -e 's/\.feature/.feature\/all\/lib/')
		local feature_platform_import=$(printf '%s' "$3" | sed -e "s/\.feature/.feature\/$_TARGET_PLATFORM\/lib/")

		_import_file_contents $1 $2 $feature_platform_import $feature_all_import
		;;
	*)
		_import_file_contents $1 $2 $_TARGET_PLATFORM/lib/$3 all/lib/$3
		;;
	esac
}

_import_file_contents() {
	local file=$1
	shift

	local line_number=$1
	shift

	_FILE_DETAIL_MESSAGE="_import_file_contents, File being updated: $PWD" _require_file "$file"
	_FILE_DETAIL_MESSAGE="_import_file_contents, Line #" _require "$line_number"

	local file_to_inject=$(mktemp)

	_debug "PWD: $PWD"

	for filepath in "$@"; do
		if [ -e $filepath ]; then
			find $filepath -type f 2>/dev/null | _import_file_contents_with_newline $file_to_inject
		else
			find $_CONF_INSTALL_APPLICATION_DATA_PATH/imports -type f -path "*/$filepath" | _import_file_contents_with_newline $file_to_inject
		fi
	done

	_insert_file_after $file $line_number $file_to_inject
}

_import_file_contents_with_newline() {
	local f
	for f in $(cat - | sort); do
		cat $f >>$1
		printf '\n' >>$1
	done
}
