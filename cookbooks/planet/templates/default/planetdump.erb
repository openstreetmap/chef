#!/bin/bash

# DO NOT EDIT - This file is being maintained by Chef

# Exit on error
set -e

# Get the name of the file and the expected pattern
file="$1"
pattern="^osm-([0-9]{4})-([0-9]{2})-([0-9]{2})\.dmp$"

# Give up now if the file isn't a database dump
[[ $file =~ $pattern ]] || exit 0

# Save the year and date from the file name
year="${BASH_REMATCH[1]}"
date="${year:2:2}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"

# Check the lock
if [ -f /tmp/planetdump.lock ]; then
    if [ "$(ps -p `cat /tmp/planetdump.lock` | wc -l)" -gt 1 ]; then
        echo "Error: Another planetdump is running"
        exit 1
    else
        rm /tmp/planetdump.lock
    fi
fi

# Create lock file
echo $$ > /tmp/planetdump.lock

# Define cleanup function
function cleanup {
    # Remove the lock file
    rm /tmp/planetdump.lock
}

# Remove lock on exit
trap cleanup EXIT

# Change to working directory
cd /store/planetdump

# Cleanup
rm -rf users
rm -rf changesets changeset_tags changeset_comments
rm -rf nodes node_tags
rm -rf ways way_tags way_nodes
rm -rf relations relation_tags relation_members

# Run the dump
time nice -n 19 /opt/planet-dump-ng/planet-dump-ng \
     --max-concurrency=4 \
     -c "pbzip2 -c" -f "/store/backup/${file}" --dense-nodes=1 \
     -C "changesets-${date}.osm.bz2" \
     -D "discussions-${date}.osm.bz2" \
     -x "planet-${date}.osm.bz2" -X "history-${date}.osm.bz2" \
     -p "planet-${date}.osm.pbf" -P "history-${date}.osm.pbf"

# Function to create bittorrent files
function mk_torrent {
  type="$1"
  format="$2"
  dir="$3"
  s_year="$4"
  web_dir="${dir}${s_year}"
  name="${type}-${date}.osm.${format}"
  web_path="${web_dir}/${name}"
  rss_web_dir="https://planet.openstreetmap.org/${dir}"
  rss_file="${type}-${format}-rss.xml"
  torrent_file="${name}.torrent"
  torrent_url="${rss_web_dir}${s_year}/${torrent_file}"

  # create .torrent file
  mktorrent -l 22 "${name}" \
     -a udp://tracker.opentrackr.org:1337 \
     -a udp://tracker.datacenterlight.ch:6969/announce,http://tracker.datacenterlight.ch:6969/announce \
     -a udp://tracker.torrent.eu.org:451 \
     -a udp://tracker-udp.gbitt.info:80/announce,http://tracker.gbitt.info/announce,https://tracker.gbitt.info/announce \
     -a http://retracker.local/announce \
     -w "https://planet.openstreetmap.org/${web_path}" \
     -w "https://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/${web_path}" \
     -w "https://ftpmirror.your.org/pub/openstreetmap/${web_path}" \
     -w "https://mirror.init7.net/openstreetmap/${web_path}" \
     -w "https://ftp.fau.de/osm-planet/${web_path}" \
     -w "https://ftp.spline.de/pub/openstreetmap/${web_path}" \
     -w "https://downloads.opencagedata.com/planet/${name}" \
     -w "https://planet.osm-hr.org/${web_path}" \
     -w "https://planet.maps.mail.ru/${web_path}" \
     -c "OpenStreetMap ${type} data export, licensed under https://opendatacommons.org/licenses/odbl/ by OpenStreetMap contributors" \
     -o "${torrent_file}" > /dev/null

  # create .xml global RSS headers if missing
  torrent_time_rfc="$(date -R -r ${torrent_file})"
  test -f "${rss_file}" || echo "<x/>" | xmlstarlet select --xml-decl --indent \
	-N "atom=http://www.w3.org/2005/Atom" \
	-N "dcterms=http://purl.org/dc/terms/" \
	-N "content=http://purl.org/rss/1.0/modules/content/" \
	--encode "UTF-8" \
	--template \
	--match / \
	--elem "rss" \
		--attr "version" --output "2.0" --break \
		--attr "atom:DUMMY" --break \
	--elem "channel" \
	--elem "title" --output "OpenStreetMap ${type} ${format} torrent RSS" --break \
	--elem "link"  --output "${rss_web_dir}" --break \
	--elem "atom:link" \
		--attr "href" --output "${rss_web_dir}/${rss_file}" --break \
		--attr "rel" --output "self" --break \
		--attr "type" --output "application/rss+xml" --break \
		--break \
	--elem "description" --output "${type}.osm.${format}.torrent RSS feed" --break \
	--elem "copyright" --output "Source: OpenStreetMap contributors, under ODbL 1.0 licence" --break \
	--elem "generator" --output "OpenStreetMap xmlstarlet powered shell script v1.0" --break \
	--elem "language" --output "en" --break \
	--elem "lastBuildDate" --output "${torrent_time_rfc}" \
	> "${rss_file}"

  # add newly created .torrent file as new entry to .xml RSS feed, removing excess entries
  torrent_size="$(stat --format="%s" ${torrent_file})"
  xmlstarlet edit --inplace \
	-a "//lastBuildDate" -t elem -n item -v ""  \
	-s "//item[1]" -t elem -n "title" -v "${torrent_file}" \
	-s "//item[1]" -t elem -n "guid" -v "${torrent_url}" \
	-s "//item[1]" -t elem -n "link" -v "${torrent_url}" \
	-s "//item[1]" -t elem -n "pubDate" -v "${torrent_time_rfc}" \
	-s "//item[1]" -t elem -n "category" -v "OpenStreetMap data" \
	-s "//item[1]" -t elem -n "enclosure" \
		-s "//item[1]"/enclosure -t attr -n "type" -v "application/x-bittorrent" \
		-s "//item[1]"/enclosure -t attr -n "length" -v "${torrent_size}" \
		-s "//item[1]"/enclosure -t attr -n "url" -v "${torrent_url}" \
	-s "//item[1]" -t elem -n "description" -v "OpenStreetMap torrent ${torrent_file}" \
	-u /rss/channel/lastBuildDate -v "${torrent_time_rfc}" \
	-d /rss/@atom:DUMMY \
	-d "//item[position()>5]" \
	"${rss_file}"
}

# Function to install a dump in place
function install_dump {
  type="$1"
  format="$2"
  dir="$3"
  year="$4"
  name="${type}-${date}.osm.${format}"
  latest="${type}-latest.osm.${format}"
  rss_file="${type}-${format}-rss.xml"

  md5sum "${name}" > "${name}.md5"
  mkdir -p "${dir}/${year}"
  mv "${name}" "${name}.md5" "${dir}/${year}"
  ln -sf "${year:-.}/${name}" "${dir}/${latest}"
  test -f "${name}.torrent" && mv "${name}.torrent" "${dir}/${year}" && ln -sf "${year:-.}/${name}.torrent" "${dir}/${latest}.torrent"
  test -f "${rss_file}" && xmllint --noout "${rss_file}" && cp -f "${rss_file}" "${dir}"
  rm -f "${dir}/${latest}.md5"
  sed -e "s/${name}/${latest}/" "${dir}/${year}/${name}.md5" > "${dir}/${latest}.md5"
}

# Create *.torrent files
mk_torrent "changesets" "bz2" "planet" "/${year}"
mk_torrent "discussions" "bz2" "planet" "/${year}"
mk_torrent "planet" "bz2" "planet" "/${year}"
mk_torrent "history" "bz2" "planet/full-history" "/${year}"
mk_torrent "planet" "pbf" "pbf"
mk_torrent "history" "pbf" "pbf/full-history"

# Move dumps into place
install_dump "changesets" "bz2" "<%= node[:planet][:dump][:xml_directory] %>" "${year}"
install_dump "discussions" "bz2" "<%= node[:planet][:dump][:xml_directory] %>" "${year}"
install_dump "planet" "bz2" "<%= node[:planet][:dump][:xml_directory] %>" "${year}"
install_dump "history" "bz2" "<%= node[:planet][:dump][:xml_history_directory] %>" "${year}"
install_dump "planet" "pbf" "<%= node[:planet][:dump][:pbf_directory] %>"
install_dump "history" "pbf" "<%= node[:planet][:dump][:pbf_history_directory] %>"
