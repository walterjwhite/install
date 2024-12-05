_APPLICATION_START_TIME=$(date +%s)

_APPLICATION_CMD=$(basename $0)

unset _DEFERS

_is_backgrounded && _BACKGROUNDED=1
[ -z "$_INSTALL_INSTALLER" ] && _PACKAGE_DISABLED=1
