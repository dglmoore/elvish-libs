fn getlogs [dir]{
	try {
		ls --color=none -1 $dir/*.log | each [log]{ basename -s .log $log } | sort -rn
	} except {
	}
}

fn punch [dir]{
	@logs=(getlogs $dir)
	
	logfile = $dir/0.log
	if (!= (count $logs) 0) {
		logfile = $dir/$logs[0].log
	}
	
	date >> $logfile
}

fn in [dir]{
	punch $dir
}

fn out [dir]{
	punch $dir
}
