_sudo() {
	if [ "$1" = "$_SUDO_CMD" ]; then
		shift
	fi

	if [ $# -eq 0 ]; then
		return
	fi

	if [ -z "$_SUDO_CMD" ]; then
		$@
		return
	fi

	if [ -z "$_NON_INTERACTIVE" ]; then
		$_SUDO_CMD -n ls >/dev/null 2>&1 || _sudo_precmd "$@"
	fi

	$_SUDO_CMD $_SUDO_OPTIONS "$@"
}
