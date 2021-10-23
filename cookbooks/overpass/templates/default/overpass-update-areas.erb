#!/bin/bash

echo "`date '+%F %T'`: update started"

if [[ -a <%= @basedir %>/db/area_version ]]; then
  sed "s/{{area_version}}/$(cat <%= @basedir %>/db/area_version)/g" <%= @srcdir %>/rules/areas_delta.osm3s | <%= @basedir %>/bin/osm3s_query --progress --rules
else
  cat <%= @srcdir %>/rules/areas.osm3s | <%= @basedir %>/bin/osm3s_query --progress --rules
fi

echo "`date '+%F %T'`: update finished"
