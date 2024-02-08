_test() {
	if [ -e test ]; then
		for _TEST_SCRIPT in $(find test -type f | sort -u); do
			. $_TEST_SCRIPT

			_TEST_STATUS=$?
			local log_level=info
			if [ $_TEST_STATUS -gt 0 ]; then
				log_level=warn
			fi

			_$log_level "$_TEST_SCRIPT => $_TEST_STATUS"

		done
	fi
}
