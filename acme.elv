fn read [file]{
    9p read acme/$E:winid/$file
}

fn write [file]{
    9p write acme/$E:winid/$file
}

fn echo [@a]{
    /usr/bin/env echo -n $@a
}

fn get {
    echo get | write ctl
}

fn put {
    echo put | write ctl
}

fn show {
    echo show | write ctl
}

fn from-body {
    read body
}

fn to-body [@a]{
    echo $@a | write body
}

fn from-addr {
    read addr
}

fn to-addr [@a]{
    echo $@a | write addr
}

fn ctl [@a]{
    echo $@a | write ctl
}

fn tag {
    read tag
}

fn name {
    tag | awk '{print $1}'
}
