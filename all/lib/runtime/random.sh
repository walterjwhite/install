_random() {
	local length=$_CONF_INSTALL_RANDOM_DEFAULT_LENGTH
	[ -n "$1" ] && {
		length=$1
		shift
	}

	openssl rand -base64 $length
}
