#!/bin/sh

_enable_debug() {
	_DEBUG=1
	set -x

	export _DEBUG
}

if [ -n "$_DEBUG" ]; then
	_enable_debug
fi

for _ARG in $@; do
	case $_ARG in
	-d | --debug)
		_enable_debug

		# remove argument
		shift

		;;
	esac
done
