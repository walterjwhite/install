_metadata_write_app() {

	printf '_APPLICATION_GIT_URL="%s"\n' "$_TARGET_APPLICATION_GIT_URL" | _metadata_write
	printf '_APPLICATION_INSTALL_DATE="%s"\n' "$_TARGET_APPLICATION_INSTALL_DATE" | _metadata_write
	printf '_APPLICATION_BUILD_DATE="%s"\n' "$_TARGET_APPLICATION_BUILD_DATE" | _metadata_write
	printf '_APPLICATION_VERSION="%s"\n' "$_TARGET_APPLICATION_VERSION" | _metadata_write
}

_metadata_write() {
	_write $_TARGET_APPLICATION_METADATA_PATH
}

_install_metadata_write() {
	_write $_APPLICATION_METADATA_PATH
}

_metadata_write_platform() {
	env | grep '^_BOOTSTRAP_' | _install_metadata_write
}
