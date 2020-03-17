use re
use github.com/dglmoore/elvish-libs/ppd

fn statfile [path]{
    stat $path | drop 1 | take 1 | eawk [@f]{ echo $f[8] }
}

fn is-dir [path]{
    ==s (statfile $path) directory
}

fn is-file [path]{
    ==s (statfile $path) regular
}

fn encrypt [path]{
    output = (re:replace '^\.' '' (basename $path).gpg)
    if (and (not ?(is-dir $path)) (not ?(is-file $path))) {
        fail "path ("$path") is neither a regular file nor a directory"
    }
    ppd:pushd (path-dir $path)
    tar czO (basename $path) 2>/dev/null | gpg --encrypt --sign -r $E:EMAIL > $output
    ppd:popd &silent=$true
    joins '/' [(path-dir $path) $output] | path-abs (all) | echo (all)
}

fn decrypt [path]{
    gpg --decrypt $path | tar xz
}

fn add-slash [path]{
    chars = [(splits '' $path)]
    if (!=s $chars[-1] '/') {
        chars = [$@chars '/']
    }
    joins '' $chars
}

fn upload [&to=backup from]{
    encrypted = (encrypt $from)
    aws s3 cp $encrypted s3://spermion/(add-slash $to)
    rm $encrypted
}
