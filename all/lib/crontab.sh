_crontab_clear() {
	crontab -f -r -u $1 2>/dev/null
}

_crontab_get() {
	_require "$1" "Crontab Filename to write to"
	crontab -l >$1 2>/dev/null
}


_crontab_write() {
	_require "$1" "Crontab User"
	_require_file "$2" "Crontab File"

	local crontab_path
	if [ "$1" = "root" ]; then
		crontab_path="$_CONF_INSTALL_CRONTAB_ROOT_PATH"
	else
		crontab_path="$_CONF_INSTALL_CRONTAB_USER_PATH"
	fi

	if [ -n "$_OPTN_INSTALL_CRONTAB_HEADER" ]; then
		printf '%s\n\n' "$_OPTN_INSTALL_CRONTAB_HEADER" >>$2.new
		cat $2 >>$2.new
		mv $2.new $2
	fi

	grep -cqm1 '^PATH=' $2.new 2>/dev/null || printf 'PATH=%s\n\n' "$crontab_path" >>$2.new

	cat $2 >>$2.new
	mv $2.new $2

	crontab -u $1 $2 || {
		_warn "error writing crontab"
		cat $2
	}
}

_crontab_append() {
	_require "$1" "Crontab User"
	_require_file "$2" "Crontab File"

	[ $(wc -l "$2" | awk {'print$1'}) -eq 0 ] && return 1

	local current_crontab=$(mktemp)
	_crontab_get $current_crontab

	case "$2" in
	/tmp/*) ;;
	*)
		printf '# %s\n\n' "$2" >>$current_crontab
		;;
	esac

	cat $2 >>$current_crontab

	_crontab_write $1 $current_crontab

	rm -f $current_crontab
}
