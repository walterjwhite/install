_syslog() {
	logger -i -t "$_APPLICATION_NAME.$_APPLICATION_CMD" "$1"
}
