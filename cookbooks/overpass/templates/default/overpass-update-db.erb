#!/bin/bash

PYOSMIUM="pyosmium-get-changes --server <%= node[:overpass][:replication_url] %> --diff-type osc.gz -f <%= @basedir %>/db/replicate-id"
<% if node[:overpass][:meta_mode] == "attic" -%>
PYOSMIUM="$PYOSMIUM --no-deduplicate"
<% end -%>

<% if node[:overpass][:meta_mode] == "meta" -%>
META=--meta
<% elsif node[:overpass][:meta_mode] == "attic" -%>
META=--keep-attic
<% else -%>
META=
<% end -%>

status=3 # make it sleep on issues

if [ -f <%= @basedir %>/db/replicate-id ]; then
  # first apply any pending updates
  if [ -f <%= @basedir %>/diffs/latest.osc ]; then
    DATA_VERSION=`osmium fileinfo -e -g data.timestamp.last <%= @basedir %>/diffs/latest.osc`
    if [ "x$DATA_VERSION" != "x" ]; then
      echo "Downloaded up to timestamp $DATA_VERSION"
      while ! <%= @basedir %>/bin/update_from_dir --osc-dir=<%= @basedir %>/diffs --version=$DATA_VERSION $META --flush-size=0; do
        echo "Error while updating. Retry in 1 min."
        sleep 60
      done
    fi
    rm <%= @basedir %>/diffs/latest.osc
  fi

  $PYOSMIUM -v -s 1000 -o <%= @basedir %>/diffs/latest.osc
  status=$?
fi

if [ $status -eq 0 ]; then
  echo "Downloaded next batch."
elif [ $status -eq 3 ]; then
  rm <%= @basedir %>/diffs/latest.osc
  echo "No new data, sleeping for a minute."
  sleep 60
else
  echo "Fatal error, stopping updates."
  exit $status
fi
