_interactive_alert() {
	which notify-send >/dev/null 2>&1 || return 1

	[ $XAUTHORITY ] && notify-send -e "$*"
}
