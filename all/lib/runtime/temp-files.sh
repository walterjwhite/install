_defer_cleanup_temp() {
	[ -z "$_TMP_CLEANUP_DEFERS" ] && _defer _cleanup_temp

	_TMP_CLEANUP_DEFERS="${_TMP_CLEANUP_DEFERS:+$_TMP_CLEANUP_DEFERS }$1"
}

_cleanup_temp() {
	if [ -n "$_TMP_CLEANUP_DEFERS" ]; then
		rm -rf $_TMP_CLEANUP_DEFERS
		unset _TMP_CLEANUP_DEFERS
	fi
}
