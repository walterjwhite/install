#!/bin/sh

_print_help() {
	if [ -e $1 ]; then
		cat $1
		echo ""
	fi
}

for _ARG in $@; do
	debug $_ARG

	case $_ARG in
	-h | --help)
		_print_help $_LIBRARY_PATH/install/help/default
		_print_help $_LIBRARY_PATH/$_APPLICATION_NAME/help/$(basename $0)

		exit 0
		;;
	esac
done
