#!/bin/sh

_TIMESTAMP_FORMAT="+%Y%m%d%H%M%S"
_LAST_UPDATE_DATE_PATH=_LIBRARY_PATH_/$_APPLICATION_NAME/.lastUpdateDate

_CHECK_FREQUENCY=daily
optionalInclude _APPLICATION_CONFIG_PATH_

_updateCheck() {
	_is_check
	if [ "$?" -eq "0" ]; then
		return
	fi

	_LATEST_APPLICATION_VERSION=$(git ls-remote $_APPLICATION_GIT_URL | head -1 | awk {'print$1'})
	_INSTALLED_APPLICATION_VERSION=$(echo $_APPLICATION_VERSION | cut -d'.' -f2)

	if [ "$_LATEST_APPLICATION_VERSION" != "$_INSTALLED_APPLICATION_VERSION" ]; then
		_update
	fi

	# update last update date
	info "Recording last update date"
	echo $(date $_TIMESTAMP_FORMAT) | $_SUDO_PROGRAM tee $_LAST_UPDATE_DATE_PATH >/dev/null
}

_is_check() {
	if [ ! -e $_LAST_UPDATE_DATE_PATH ]; then
		return 1
	fi

	if [ $_NON_INTERACTIVE -gt 0 ]; then
		return 0
	fi

	_LAST_UPDATED=$(cat $_LAST_UPDATE_DATE_PATH)
	case $_CHECK_FREQUENCY in
	daily)
		_EXPIRATION=$(date -v-1d $_TIMESTAMP_FORMAT)
		;;
	weekly)
		_EXPIRATION=$(date -v-1w $_TIMESTAMP_FORMAT)
		;;
	monthly)
		_EXPIRATION=$(date -v-1m $_TIMESTAMP_FORMAT)
		;;
	hourly)
		_EXPIRATION=$(date -v-1H $_TIMESTAMP_FORMAT)
		;;
	*)
		warn "Unknown _CHECK_FREQUENCY $_CHECK_FREQUENCY"
		return 1
		;;
	esac

	_require "$_LAST_UPDATED" "Last Updated" 3
	_require "$_EXPIRATION" "Expiration" 4

	return $(echo "$_LAST_UPDATED < $_EXPIRATION" | bc)
}

_update() {
	if [ -z "$_AUTO_UPDATE" ]; then
		_continueif "($_APPLICATION_NAME) $_LATEST_APPLICATION_VERSION is available ($_INSTALLED_APPLICATION_VERSION), upgrade" "Y/n"
		_do_update
	else
		_do_update
	fi
}

_do_update() {
	info "Attempting to update"
	$_SUDO_PROGRAM app-install $_APPLICATION_GIT_URL
}

if [ -n "$_UPDATE_CHECK" ]; then
	_updateCheck
else
	warn "Auto-update is disabled"
fi
