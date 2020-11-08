#!/usr/bin/env elvish

fn statfile [path]{
    stat $path | drop 1 | take 1 | eawk [@f]{ echo $f[8] }
}

fn is-dir [path]{
    ==s (statfile $path) directory
}

fn get-key [container key default]{
    value = $default
    if (has-key $container $key) {
        value = $container[$key]
    }
    put $value
}

fn get-instances [response]{
        instances = [["Name" "ID" "State" "IP Address"]]
    each [reservation]{
        each [instance]{
            each [tag]{
                if (==s $tag["Key"] "Name") {
                    name = $tag["Value"]
                    id = $instance["InstanceId"]
                    state = $instance["State"]["Name"]
                    ip = (get-key $instance "PublicIpAddress" "")

                    details = [$name $id $state $ip]
                    instances = [$@instances $details]
                }
            } $instance["Tags"]
        } $reservation["Instances"]
    } $response["Reservations"]
    put $instances
}

fn pad [n s]{
    l = (count $s)
    if (> $n $l) {
        p = (repeat (- $n $l) " " | joins '')
        s = $s$p
    }
    put $s
}

fn make-row [row lengths]{
    s = ""
        each [i]{
        s = $s(pad $lengths[$i] $row[$i])" "
    } [(seq 0 (- (count $lengths) 1))]
        put $s
}

fn make-sep [lengths]{
    s = ""
    each [l]{
        s = $s(repeat $l "-" | joins '')" "
    } $lengths
    put $s
}

fn map [f xs]{
    ys = []
    each [x]{ ys = [$@ys ($f $x)] } $xs
    put $ys
}

fn to-table [rows]{
    lengths = []
    each [header]{
        lengths = [$@lengths (count $header)]
    } $rows[0]

    each [row]{
        each [i]{
            l = (count $row[$i])
            if (< $lengths[$i] $l) {
                 lengths[$i] = $l
            }
        } [(seq 0 (- (count $lengths) 1))]
    } $rows[1:]

    add-one = [x]{ put (+ $x 1) }
    lengths = (map $add-one $lengths)

    echo (make-row $rows[0] $lengths)
    echo (make-sep $lengths)
    each [row]{ echo (make-row $row $lengths) } $rows[1:]
}

fn instances []{
    get-instances (e:aws ec2 describe-instances | from-json) | to-table (all)
}

fn get-instance-id [name]{
    instances | grep $name | awk '{ print $2 }'
}

fn get-instance-ip [name]{
    instances | grep $name | awk '{ print $4 }'
}

fn start-instance [name]{
    e:aws ec2 start-instances --instance-ids (get-instance-id $name)
}

fn stop-instance [&hibernate=$true name]{
    id = (get-instance-id $name)

    if (bool $hibernate) {
        e:aws ec2 stop-instances --instance-ids $id --hibernate
    } else {
        e:aws ec2 stop-instances --instance-ids $id
    }
}

fn ssh [name &user="ec2-user" @args]{
    e:ssh $@args $user@(get-instance-ip $name)
}

fn sftp [name &user="ec2-user" @args]{
    e:sftp $@args $user@(get-instance-ip $name)
}

fn sshfs [name &user="ec2-user" &at="" &dir="" @args]{
    if (==s $at "") {
        at = $name
    }
    if (not ?(is-dir $at > /dev/null 2>&1)) {
        mkdir $at
    }
    e:sshfs $user@(get-instance-ip $name):$dir $at
}

fn sam [name &user="ec2-user" @args]{
    e:sam -r $user@(get-instance-ip $name) $@args &
}
