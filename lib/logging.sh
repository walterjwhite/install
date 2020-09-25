#!/bin/sh

exitWithError() {
    >&2 echo $1
    exit $2
}

exitSuccess() {
    echo $1
    exit 0
}

_() {
    # use log function ~/.logging
    echo $@
    #logger -i -t "" $1

    if [ -z "$_DRY_RUN" ]
    then
        $@
    fi
}