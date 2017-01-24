#!/bin/bash

RRD_DIR=/var/lib/munin/openstreetmap
DIR=`mktemp -d`

function cleanup {
  rm -rf "$DIR"
}

trap cleanup EXIT

cd "$RRD_DIR"
for f in *.rrd; do
  rrdtool dump "$f" "$DIR/${f}.xml"
  touch -r "$f" "$DIR/${f}.xml"
done

cd "$DIR"
find -name "*.xml" -print0 | tar zcf - --null -T -
