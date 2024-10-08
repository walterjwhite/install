_beep() {
	if [ -n "$_BEEPING" ]; then
		_debug "Another 'beep' is in progress"
		return 1
	fi

	_BEEPING=1
	_do_beep "$@" &
}

_do_beep() {
	if [ -e /dev/speaker ]; then
		printf '%s' "$1" >/dev/speaker
	fi

	unset _BEEPING
}

_sudo_precmd() {
	_beep $_CONF_INSTALL_SUDO_BEEP_TONE
}
