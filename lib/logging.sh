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

    >&2 echo -e "\e[31m$1\e[0m\n"
    exit $2
}

exitSuccess() {
    echo -e "\e[32m$1\e[0m\n"
    exit 0
}

warn() {
    echo -e "\e[33m$1\e[0m\n"
}

info() {
    echo -e "\e[36m$1\e[0m\n"
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

        local _exitStatus=$?
        if [ "$_exitStatus" -gt "0" ]
        then
            if [ -z "$WARN_ON_ERROR" ]
            then
                exitWithError "Previous cmd failed" $_exitStatus
            else
                warn "Previous cmd failed - $@ - $_exitStatus"
            fi
        fi
    else
        echo $@
    fi
}

_in_data_path() {
    return $(pwd | grep -c $_DATA_PATH)
}