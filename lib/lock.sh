#!/bin/sh

trap _cleanup 0 1 2 INT

# @TODO: this only supports a single user
_LOCKFILE=/tmp/$(basename $0).lock

_lock() {
	if [ -e $_LOCKFILE ]; then
		exitWithError "$_LOCKFILE exists, sleeping" 5
	fi

	touch $_LOCKFILE
}

_cleanup() {
	rm -f $_LOCKFILE
}
