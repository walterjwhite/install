_mktemp() {
	mktemp -t ${_APPLICATION_NAME}.${_APPLICATION_CMD}.$1
}
