_mail() {
	if [ $# -lt 3 ]; then
		_warn "recipients[0], subject[1], message[2] is required - $# arguments provided"
		return 1
	fi

	local recipients=$(printf '%s' "$1" | tr '|' ' ')
	shift

	local subject="$1"
	shift

	local message="$1"
	shift

	printf "$message" | mail -s "$subject" $recipients
}
