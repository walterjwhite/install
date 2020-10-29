#!/bin/sh

if [ -n "$_DEBUG" ]
then
    echo "Application Name: $_APPLICATION_NAME:$_APPLICATION_VERSION" "$_APPLICATION_BUILD_DATE / $_APPLICATION_INSTALL_DATE @ $_APPLICATION_DATA_PATH"
    set -x
fi

optionalInclude() {
    if [ -e $1 ]
    then
        . $1
    else
        warn "$1 does NOT exist"
    fi
}

exitWithError() {
    _ERROR=$2

    >&2 printf "\033[0;31m$1\033[0m\n"
    exit $2
}

exitSuccess() {
    printf "\033[0;32m$1\033[0m\n"
    exit 0
}

warn() {
    printf "\033[1;33m$1\033[0m\n"
}

_require() {
    if [ -z "$1" ]
    then
        exitWithError "$2 required" $3
    fi
}

_read_if() {
    if [ -z "$1" ]
    then
        echo "Enter $2"
        read $3
    fi
}

_() {
    if [ -z "$_DRY_RUN" ]
    then
        $@

        _exitStatus=$?
        if [ "$_exitStatus" -gt "0" ]
        then
            exitWithError "Previous cmd failed" $_exitStatus
        fi
    else
        echo $@
    fi
}

_in_data_path() {
    return $(pwd | grep -c $_DATA_PATH)
}