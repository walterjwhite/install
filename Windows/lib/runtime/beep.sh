_beep() {
	[ $# -eq 0 ] && return 1

	if [ -n "$_BEEPING" ]; then
		_debug "Another 'beep' is in progress"
		return 2
	fi

	_BEEPING=1
	_do_beep "$@" &
}

_do_beep() {

	powershell "[console]::beep($1)"

	unset _BEEPING
}
