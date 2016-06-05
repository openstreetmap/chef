#!/usr/bin/env python

# The MIT License (MIT)
# Copyright (c) 2016 Adrian Frith (htonl)
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import sys, os, subprocess, glob, csv

tiffdir = 'source'
coldir = 'colvrts'
finaldir = 'vrts'

reader = csv.reader(open('ngi-250k-sheet-edges.csv'))
next(reader)    #discard header row

for row in reader:
  sheet = row[0]

  orfile = '%s/%s' % (tiffdir, row[1])
  colfile = '%s/%s.vrt' % (coldir, sheet)
  trimfile = '%s/%s.vrt' % (finaldir, sheet)

  (west, south, east, north) = map(float, row[2:])

  print('gdal_translate -expand rgba -of VRT %s %s' % (orfile, colfile))
  print('gdalwarp -tps -r cubicspline -s_srs EPSG:4326 -t_srs EPSG:3857 -te %f %f %f %f -of VRT %s %s' % (west, south, east, north, colfile, trimfile))
