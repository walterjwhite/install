_warn_duplicate_functions() {
	_warn 'Duplicated functions'
	find . -type f ! -path '*/.git/*' ! -exec grep \(\) {} + | $_CONF_INSTALL_GNU_GREP -Po '[_a-zA-Z0-9]{3,}\(\)' | uniq -d | sort -u
}
