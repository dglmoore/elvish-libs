fn runtests [&sleep=0.25 &clear=$true @args]{
    try {
		if (bool $clear) {
	        clear
		}
		sleep $sleep
        phpunit -c test/phpunit.xml --whitelist src $@args
    } except { }
}

fn test [&loop=true &sleep=0.25 @args]{
	runtests &sleep=$sleep &clear=$loop $@args

	if (bool $loop) {
        while ?(inotifywait -qq -e modify -r src -r test) {
			runtests &sleep=$sleep $@args
        }
	}
}
