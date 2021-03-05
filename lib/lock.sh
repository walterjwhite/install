#!/bin/sh

trap _unlock 0 1 2 INT

_LOCKFILE=/tmp/$(whoami)/$(basename $0).lock

_lock() {
	if [ -e $_LOCKFILE ]; then
		exitWithError "$_LOCKFILE exists" 5
	fi

	mkdir -p $(dirname $_LOCKFILE)
	touch $_LOCKFILE
}

_unlock() {
	rm -f $_LOCKFILE
}
