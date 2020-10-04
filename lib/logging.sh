#!/bin/sh

. _APPLICATION_CONFIG_PATH_

if [ -n "$_DEBUG" ]
then
    doLog "Application Name: $_APPLICATION_NAME:$_APPLICATION_VERSION" "$_APPLICATION_BUILD_DATE / $_APPLICATION_INSTALL_DATE @ $_APPLICATION_DATA_PATH"
    set -x
fi

exitWithError() {
    >&2 echo $1
    exit $2
}

exitSuccess() {
    echo $1
    exit 0
}

_() {
    doLog $@

    if [ -z "$_DRY_RUN" ]
    then
        $@

        _exitStatus=$?
        if [ "$_exitStatus" -gt "0" ]
        then
            exitWithError "Previous cmd failed" $_exitStatus
        fi
    fi
}