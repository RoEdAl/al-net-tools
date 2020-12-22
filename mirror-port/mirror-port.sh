#!/bin/bash -e

function show_usage() {
    echo "Usage: ${0/*\//} <src interface> start|stop [<dst interface>]"
}

if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

SRCIFACE="$1"           # source interface
COMMAND="$2"            # start or stop
DSTIFACE="${3:-br-mrr}" # mirror interface (br-mrr by default) 

function mirror_start() {
    # ingress
    tc qdisc add dev ${SRCIFACE} ingress
    tc filter add dev ${SRCIFACE} parent ffff: \
          matchall skip_hw \
          action mirred egress mirror dev ${DSTIFACE}

    # egress
    tc qdisc add dev $SRCIFACE handle 1: root prio
    tc filter add dev $SRCIFACE parent 1: \
          matchall skip_hw \
          action mirred egress mirror dev ${DSTIFACE}
}

function mirror_stop() {
    tc qdisc del dev ${SRCIFACE} ingress
    tc qdisc del dev ${SRCIFACE} root
}

case ${COMMAND} in
    start)
        mirror_start
        ;;

   stop)
        mirror_stop
        ;;
   *)
        schow_usage;
        exit 1
       ;;
esac

