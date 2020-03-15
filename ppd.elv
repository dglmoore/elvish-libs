DIRSTACK=[]

fn pushd [dir]{
    from=$pwd
    if (builtin:cd $dir) {
        DIRSTACK = [$from $@DIRSTACK]
    }
}

fn popd []{
    if (< (count $DIRSTACK) 1) {
        echo "directory stack is empty"
    } elif ?(builtin:cd (take 1 $DIRSTACK)) {
        DIRSTACK = $DIRSTACK[1:]
    }
}
