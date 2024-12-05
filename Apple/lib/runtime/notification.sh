_notify() {
	local title=$1
	local message=$2

	osascript -e "display notification \"$message\" with title \"$_APPLICATION_NAME - $_APPLICATION_CMD - $title\""
}
