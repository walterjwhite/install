_is_app() {
	[ ! -e .app ] && _error ".app does NOT exist, is this an app ($PWD)" 3
}

_is_clean() {
	[ -n "$(git status --porcelain)" ] && _error "Working directory is dirty, please commit changes first"
}
