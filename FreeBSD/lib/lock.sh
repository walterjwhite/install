_lock() {
	local lock_timeout=$1
	shift

	local lock_file=$1
	shift

	if [ "$#" -eq 0 ]; then
		_error "_lock requires at least 3 arguments, timeout (1), lock file (2), and cmd (3)"
	fi

	lockf -t $lock_timeout $lock_file "$@"
}
