#!/bin/sh

for _ARG in $@; do
	case $_ARG in
	-h | --help)
		_HELP_FILE=$_LIBRARY_PATH/$_APPLICATION_NAME/help/$(basename $0)

		if [ -e $_HELP_FILE ]; then
			cat $_HELP_FILE
			exit 0
		fi

		;;
	esac
done
