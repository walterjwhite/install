_sed_safe() {
	printf '%s' $1 | sed -e "s/\//\\\\\//g"
}
