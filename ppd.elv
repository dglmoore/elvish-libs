DIRSTACK = []

fn pushd [@args]{
    dir = $E:HOME
    if (>= (count $args) 1) {
        dir = $args[0]
        args = $args[1:]
    }
    if (!=s $dir $pwd) {
        from = $pwd
        if (builtin:cd $dir) {
            DIRSTACK = [$from $@DIRSTACK]
            if (>= (count $args) 1) {
                pushd $@args
            }
        }
    }
}

fn popd [&n=1 &silent=$false]{
    if (> $n 0) {
        if (< (count $DIRSTACK) 1) {
            if (not (bool $silent)) {
                echo "directory stack is empty"
            }
        } else {
            to=(take 1 $DIRSTACK)
            if ?(builtin:cd $to) {
                DIRSTACK = $DIRSTACK[1:]
                if (not (bool $silent)) {
                    put $to
                }
                popd &n=(- $n 1) &silent=$silent
            }
        }
    }
}

fn cleard {
    DIRSTACK = []
}

fn putd {
    put $@DIRSTACK
}
