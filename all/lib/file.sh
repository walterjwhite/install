_require_file() {
	if [ -z "$1" ]; then
		_error "Filename is missing ($_FILE_DETAIL_MESSAGE)"
	fi

	if [ ! -e $1 ]; then
		if [ $# -eq 2 ]; then
			_warn "File: $1 does not exist ($_FILE_DETAIL_MESSAGE)"
			return 1
		fi

		_error "File: $1 does not exist ($_FILE_DETAIL_MESSAGE)"
	fi
}

_readlink() {
	if [ $# -lt 1 ] || [ -z "$1" ]; then
		return 1
	fi

	if [ "$1" = "/" ]; then
		printf '%s\n' "$1"
		return
	fi

	if [ ! -e $1 ]; then
		if [ -z $_MKDIR ] || [ $_MKDIR -eq 1 ]; then
			local sudo
			if [ -n "$_USE_SUDO" ]; then
				sudo=$_SUDO_CMD
			fi

			$sudo mkdir -p $1 >/dev/null 2>&1
		fi
	fi

	readlink -f $1
}
