#!/bin/bash

RRD_DIR=/var/lib/munin/openstreetmap
DIR=`mktemp -d`
DUMP_DIR=/srv/munin.openstreetmap.org/dumps
TARGET_TGZ=`date "+munin-data-%Y-%m-%d.tar.gz"`
KEEP_OLD_COUNT=3

function cleanup {
  rm -rf "$DIR"
}

trap cleanup EXIT

set -e

cd "$RRD_DIR"
for f in *.rrd; do
  rrdtool dump "$f" "$DIR/${f}.xml"
  touch -r "$f" "$DIR/${f}.xml"
done

cd "$DIR"
find -name "*.xml" -print0 | tar zcf "dump.tar.gz" --null -T -

# if we got here, then the file was created okay so we're okay to delete any
# old files.
find "${DUMP_DIR}" -name "munin-data-*.tar.gz" -print0 | \
    sort -z -r | \
    tail -z -n "+${KEEP_OLD_COUNT}" | \
    xargs --null rm -f

mv dump.tar.gz "${DUMP_DIR}/${TARGET_TGZ}"
