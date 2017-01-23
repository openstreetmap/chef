#!/bin/bash

RRD_DIR=/var/lib/munin/openstreetmap
DIR=`mktemp -d`
NPROCS=8

function cleanup {
rm -rf "$DIR"
}

trap cleanup EXIT

cd "$RRD_DIR"
find -name "*.rrd" -print0 | xargs --null --max-procs=$NPROCS -I {} rrdtool dump {} "$DIR/{}.xml"

cd "$DIR"
find -name "*.xml" -print0 | tar zcf - --null -T -
