_last_import_line() {
	local last_import_line=$(grep -n import "$1" | tail -1 | sed -e 's/\:.*$//')
	if [ -z "$last_import_line" ]; then
		last_import_line=1
	fi

	last_import_line=$(($last_import_line + 1))
	printf '%s\n' "$last_import_line"
}

_last_default_line() {
	local last_default_line=$($_CONF_INSTALL_GNU_GREP -Pn '^: \$\{_CONF_' "$1" | tail -1 | sed -e 's/\:.*$//')
	if [ -z "$last_default_line" ]; then
		last_default_line=1
	fi

	last_default_line=$(($last_default_line + 1))
	printf '%s\n' "$last_default_line"
}

_insert_after() {
	head -$3 $1 >$1.before
	sed "1,${3}d" $1 >$1.after

	if [ -e "$2" ]; then
		cat "$2" >>$1.before
	else
		printf '%s\n' "$2" >>$1.before
	fi

	cat $1.after >>$1.before
	mv $1.before $1

	chmod +x $1

	rm -f $1.after

	printf '\n' >>$1
}

_insert_file_after() {
	if [ $2 -gt 1 ]; then
		local head_line=$(($2 - 1))
		head -$head_line $1 >$1.before

		sed "1,${2}d" $1 >$1.after
	else
		touch $1.before
		sed 1d $1 >$1.after
	fi

	cat $3 >>$1.before
	cat $1.after >>$1.before

	rm -f $1.after
	mv $1.before $1

	chmod +x $1

	printf '\n' >>$1

	rm -f $3
}

_import_file_contents_all() {
	_FILE_DETAIL_MESSAGE="_do_import_file_contents_all, File being updated" _require_file "$1"

	if [ -z "$2" ]; then
		return 1
	fi


	cp $2 $2.out
	cat $1 >>$2.out

	$_CONF_INSTALL_GNU_SED -i 's/^#!\/bin\/sh$//' $2.out

	$_CONF_INSTALL_GNU_SED -i '1 i #!/bin/sh' $2.out

	mv $2.out $1
	chmod +x $1

	printf '\n' >>$1
}
