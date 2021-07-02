WHALE = (e:cat $E:HOME/.elvish/whale.json | from-json)

fn ssh [&machine=whale @a]{
    e:ssh -i ~/.ssh/whale_rsa $@a $WHALE["machines"][$machine]
}

fn scp [&machine=whale from to @a]{
    e:scp -i ~/.ssh/whale_rsa $@a $WHALE["machines"][$machine]:$from $to
}

fn sftp [&machine=whale @a]{
    e:sftp -i ~/.ssh/whale_rsa $@a $WHALE["machines"][$machine]
}

fn tunnel [&port=3305 &machine=whale @a]{
    ssh &machine=$machine -L $port":127.0.0.1:3306" $@a
}

fn db [&port=3305 db @a]{
    user = $WHALE["databases"][$db]["user"]
    password = $WHALE["databases"][$db]["password"]

    if (has-key $WHALE["databases"][$db] "db") {
        database = $WHALE["databases"][$db]["db"]
        mysql --host 127.0.0.1 --port $port --user $user -p$password $database $@a
    } else {
        mysql --host 127.0.0.1 --port $port --user $user -p$password $@a
    }
}

fn curl [&auth="" @a]{
    if (!=s $auth "") {
        user = $WHALE["basic_auth"][$auth]["user"]
        password = $WHALE["basic_auth"][$auth]["password"]
        e:curl -u $user":"$password $@a
    } else {
        e:curl $@a
    }
}
