#!/usr/bin/env python

from time import time
from os import stat, environ
from re import search

def nice_size(file):
    size = stat(file).st_size
    KB = 1024.
    MB = 1024. * KB
    GB = 1024. * MB
    TB = 1024. * GB

    if size < KB:
        size, suffix = size, ''
    elif size < MB:
        size, suffix = size/KB, 'KB'
    elif size < GB:
        size, suffix = size/MB, 'MB'
    elif size < TB:
        size, suffix = size/GB, 'GB'
    else:
        size, suffix = size/TB, 'TB'

    if size < 10:
        return '%.1f %s' % (round(size,1), suffix)
    else:
        return '%d %s' % (round(size), suffix)

def nice_time(time):
    if time < 15:
        return 'moments'
    if time < 90:
        return '%d seconds' % time
    if time < 60 * 60 * 1.5:
        return '%d minutes' % (time / 60.)
    if time < 24 * 60 * 60 * 1.5:
        return '%d hours' % (time / 3600.)
    if time < 7 * 24 * 60 * 60 * 1.5:
        return '%d days' % (time / 86400.)
    if time < 30 * 24 * 60 * 60 * 1.5:
        return '%d weeks' % (time / 604800.)

    return '%d months' % (time / 2592000.)

def file_info(file, name):
    torrent_file = file + '.torrent'
    size = nice_size(file)
    hash = search(r'\w{32}', open(file+'.md5', 'r').read()).group(0)
    date = nice_time(time() - stat(file).st_mtime)

    return '<b><a href="%(file)s">%(name)s</a> (<a href="%(torrent_file)s">torrent</a>)</b><br><b>%(size)s</b>, created %(date)s ago.<br><small>md5: %(hash)s</small>.' % locals()

planet_link = file_info('history-latest.osm.bz2', 'Latest Full History Planet XML File')
planet_pbf_link = file_info('../../pbf/full-history/history-latest.osm.pbf', 'Latest Full History Planet PBF File')

print """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Index of /planet/full-history</title>
  <link href="https://planet.openstreetmap.org/style.css" rel="stylesheet" type="text/css">
 </head>
 <body>
<img id="logo" src="https://planet.openstreetmap.org/logo.png" alt="OSM logo" width="128" height="128">
<h1>Planet OSM</h1>

<p>
The files found here are complete copies of the OpenStreetMap.org
database, including editing history. These are published under an
Open Data Commons Open Database License 1.0 licensed. For more
information, <a href="https://wiki.openstreetmap.org/wiki/Planet.osm/full">see the project wiki</a>.
</p>

<table id="about">
  <tr>
    <th>
        <h2>Complete OSM Data History</h2>
    </th>
    <th>
        <h2>Using The Data</h2>
    </th>
    <th>
        <h2>Extracts &amp; Mirrors</h2>
    </th>
  </tr>
  <tr>
    <td>
        <p>%(planet_link)s</p>
        <p>%(planet_pbf_link)s</p>
        <p>
	The full history planet file contains the full editing history of the OpenStreetMap
	database in both XML and custom PBF formats.
        </p>
    </td>
    <td>
        <p>
        You are granted permission to use OpenStreetMap data by
        <a href="https://osm.org/copyright">the OpenStreetMap License</a>, which also describes
        your obligations.
        </p>
        <p>
        You can <a href="https://wiki.openstreetmap.org/wiki/Planet.osm/full#Processing">process the file</a>
        or extracts with a variety of tools, although some tools for processing OSM data will
	only work on 'current' planets and will not process a 'history' planet available here.
        </p>
    </td>
    <td>
        <p>
        The complete history planet is extremely large, so you may prefer to use one of
        <a href="https://wiki.openstreetmap.org/wiki/Planet.osm/full#Extracts">the available extracts</a>
        (individual countries or states) from third parties.
        </p>
    </td>
  </tr>
</table>

<p>
If you find data within OpenStreetMap that you believe is an infringement of someone else's copyright, then please make contact with the <a href="https://wiki.openstreetmap.org/wiki/Data_working_group">OpenStreetMap Data Working Group</a>.
</p>
""" % locals()
