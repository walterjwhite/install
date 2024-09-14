_sudo() {
	[ $# -eq 0 ] && _error 'No arguments were provided to _sudo'

	[ $(whoami) == 'root' ] && [ -z $_SUDO_REQUIRED ] && {
		$@
		return
	}

	_require "$_SUDO_CMD" _SUDO_CMD

	if [ -z "$_NON_INTERACTIVE" ]; then
		$_SUDO_CMD -n ls >/dev/null 2>&1 || _sudo_precmd "$@"
	fi

	$_SUDO_CMD $_SUDO_OPTIONS "$@"
}
