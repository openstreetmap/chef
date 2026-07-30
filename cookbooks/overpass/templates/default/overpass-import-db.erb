#!/bin/bash -e

FNAME=$1

if [[ "x$FNAME" == "x" ]]; then
  echo "Usage: overpass-import-db <OSM file>"
  exit 1
fi

case "$FNAME" in
  *.gz) UNPACKER='gunzip -c' ;;
  *.bz2) UNPACKER='bunzip2 -c' ;;
  *) UNPACKER='osmium cat -o - -f xml' ;;
esac

<% if node[:overpass][:meta_mode] == "meta" -%>
META=--meta
<% elsif node[:overpass][:meta_mode] == "attic" -%>
META=--keep-attic
<% else -%>
META=
<% end -%>

sudo systemctl stop overpass-area-processor || true
sudo systemctl stop overpass-update || true
sudo systemctl stop overpass-area-dispatcher || true
sudo systemctl stop overpass-dispatcher || true

sleep 2

# Remove old database
sudo -u <%= @username %> rm -rf <%= @basedir %>/db/*

$UNPACKER $FNAME | sudo -u <%= @username %> <%= @basedir %>/bin/update_database --db-dir='<%= @basedir %>/db' --compression-method=<%= node[:overpass][:compression_mode] %> --map-compression-method=<%= node[:overpass][:compression_mode] %> $META

sudo -u <%= @username %> ln -s <%= @srcdir %>/rules <%= @basedir %>/db/rules

echo "Import finished. Catching up with new changes."

sudo systemctl start overpass-dispatcher
sudo systemctl start overpass-area-dispatcher

PYOSMIUM="sudo -u <%= @username %> pyosmium-get-changes --server <%= node[:overpass][:replication_url] %> --diff-type osc.gz -f <%= @basedir %>/db/replicate-id"
<% if node[:overpass][:meta_mode] == "attic" -%>
PYOSMIUM="$PYOSMIUM --no-deduplicate"
<% end -%>

# Get the replication id
$PYOSMIUM -v -O $FNAME --ignore-osmosis-headers

sudo -u <%= @username %> rm -f <%= @basedir %>/diffs/*

while $PYOSMIUM -v -s 1000 -o <%= @basedir %>/diffs/latest.osc; do
  if [ ! -f <%= @basedir %>/db/replicate-id ]; then
    echo "Replication ID not written."
    exit 1
  fi
  DATA_VERSION=`osmium fileinfo -e -g data.timestamp.last <%= @basedir %>/diffs/latest.osc`
  echo "Downloaded up to timestamp $DATA_VERSION"
  while ! sudo -u <%= @username %> <%= @basedir %>/bin/update_from_dir --osc-dir=<%= @basedir %>/diffs --version=$DATA_VERSION $META --flush-size=0; do
    echo "Error while updating. Retry in 1 min."
    sleep 60
  done
  sudo -u <%= @username %> rm <%= @basedir %>/diffs/latest.osc
  echo "Finished up to $DATA_VERSION."
done

echo "DB up-to-date. Processing areas."

sudo -u <%= @username %> <%= @basedir %>/bin/osm3s_query --progress --rules <<%= @srcdir %>/rules/areas.osm3s

echo "All updates done."
