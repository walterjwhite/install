_parallel() {
	find $1 -type f | xargs -L1 -P$2 sh
}
