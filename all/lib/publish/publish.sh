_push_changes() {
	printf '_APPLICATION_NAME=%s\n_APPLICATION_VERSION=%s\n_APPLICATION_BUILD_DATE=%s\n' "$_TARGET_APPLICATION_NAME" "$_TARGET_APPLICATION_VERSION" "$_TARGET_APPLICATION_BUILD_DATE" >$_TARGET_APPLICATION_NAME/.app

	git add $_TARGET_APPLICATION_NAME
	git commit $_TARGET_APPLICATION_NAME -m "$_TARGET_APPLICATION_NAME - $_TARGET_APPLICATION_VERSION"
	git push
}

_tag_published_build() {
	cd $_opwd
	git tag publish/$(date %Y/%m/%d/%s)
	git push

	unset _opwd
}

_prepare_registry() {
	_info "Preparing registry"

	_PUBLISH_WORK_DIRECTORY=$_CONF_INSTALL_DATA_REGISTRY_PATH
	_opwd=$PWD
	if [ -e $_PUBLISH_WORK_DIRECTORY ]; then
		cd $_PUBLISH_WORK_DIRECTORY
		git pull
	else
		git_mirrors=$_CONF_INSTALL_APP_REGISTRY_GIT_URL _do_clone $_PUBLISH_WORK_DIRECTORY || _error "Unable to clone app registry"
		cd $_PUBLISH_WORK_DIRECTORY
	fi
}

_update_artifacts() {
	_info "Updating artifacts for $_TARGET_APPLICATION_NAME"

	[ -e $_TARGET_APPLICATION_NAME ] && cp $_TARGET_APPLICATION_NAME/.app old.app

	rm -rf $_TARGET_APPLICATION_NAME
	cp -Rp $_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME $_TARGET_APPLICATION_NAME
	rm -f $_TARGET_APPLICATION_NAME/.build-date

	[ -e old.app ] && mv old.app $_TARGET_APPLICATION_NAME/.app
}

_app_publish_recursive() {
	local app opwd
	opwd=$PWD
	for app in $(find . -maxdepth 2 -type f -name .app | sed -e 's/\/\.app$//' -e 's/^\.\///'); do
		cd $app
		_app_publish_instance
		cd $opwd
	done
}

_app_publish_instance() {
	_TARGET_APPLICATION_NAME=$(basename $PWD)
	_TARGET_APPLICATION_VERSION=$(git rev-parse HEAD)
	_TARGET_APPLICATION_BUILD_DATE=$(cat $_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME/.build-date)

	_require_file $_CONF_INSTALL_DATA_ARTIFACTS_PATH/$_TARGET_APPLICATION_NAME "No artifacts to publish"

	_is_app
	_is_clean

	_prepare_registry
	_update_artifacts

	if [ -n "$(git status --porcelain $_TARGET_APPLICATION_NAME)" ]; then
		_info "Publishing changes"
		_push_changes
	else
		_warn "No changes detected"
	fi
}
