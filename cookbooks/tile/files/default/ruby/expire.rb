#!/usr/bin/ruby

require 'rubygems'
require 'proj4'
require 'xml/libxml'
require 'set'
require 'time'
require 'mmap'

module Expire
  # projection object to go from latlon -> spherical mercator
  PROJ = Proj4::Projection.new(["+proj=merc", "+a=6378137", "+b=6378137",
                                "+lat_ts=0.0", "+lon_0=0.0", "+x_0=0.0",
                                "+y_0=0", "+k=1.0", "+units=m",
                                "+nadgrids=@null", "+no_defs +over"])

  # width/height of the spherical mercator projection
  SIZE = 40075016.6855784
  # the size of the meta tile blocks
  METATILE = 8
  # the directory root for meta tiles
  HASH_ROOT = "/tiles/default/"
  # node cache file
  NODE_CACHE_FILE = "/store/database/nodes"

  # turns a spherical mercator coord into a tile coord
  def self.tile_from_merc(point, zoom)
    # renormalise into unit space [0,1]
    point.x = 0.5 + point.x / SIZE
    point.y = 0.5 - point.y / SIZE
    # transform into tile space
    point.x = point.x * 2**zoom
    point.y = point.y * 2**zoom
    # chop of the fractional parts
    [point.x.to_int, point.y.to_int, zoom]
  end

  # turns a latlon -> tile x,y given a zoom level
  def self.tile_from_latlon(latlon, zoom)
    # first convert to spherical mercator
    point = PROJ.forward(latlon)
    tile_from_merc(point, zoom)
  end

  # this must match the definition of xyz_to_meta in mod_tile
  def self.xyz_to_meta(x, y, z)
    # mask off the final few bits
    x &= ~(METATILE - 1)
    y &= ~(METATILE - 1)
    # generate the path
    hash_path = (0..4).collect do |i|
      (((x >> 4 * i) & 0xf) << 4) | ((y >> 4 * i) & 0xf)
    end.reverse.join('/')
    z.to_s + '/' + hash_path + ".meta"
  end

  # time to reset to, some very stupidly early time, before OSM started
  EXPIRY_TIME = Time.parse("2000-01-01 00:00:00")

  # expire the meta tile by setting the modified time back
  def self.expire_meta(meta)
    puts "Expiring #{meta}"
    File.utime(EXPIRY_TIME, EXPIRY_TIME, meta)
  end

  def self.expire(change_file, min_zoom, max_zoom, tile_dirs)
    do_expire(change_file, min_zoom, max_zoom) do |set|
      new_set = Set.new
      meta_set = Set.new

      # turn all the tiles into expires, putting them in the set
      # so that we don't expire things multiple times
      set.each do |xy|
        # this has to match the routine in mod_tile
        meta = xyz_to_meta(xy[0], xy[1], xy[2])

        # check each style working out what needs expiring
        tile_dirs.each do |tile_dir|
          meta_set.add(tile_dir + "/" + meta) if File.exist?(tile_dir + "/" + meta)
        end

        # add the parent into the set for the next round
        new_set.add([xy[0] / 2, xy[1] / 2, xy[2] - 1])
      end

      # expire all meta tiles
      meta_set.each do |meta|
        expire_meta(meta)
      end

      # return the new set, consisting of all the parents
      new_set
    end
  end

  def self.do_expire(change_file, min_zoom, max_zoom, &_)
    # read in the osm change file
    doc = XML::Document.file(change_file)

    # hash map to contain all the nodes
    nodes = {}

    # we put all the nodes into the hash, as it doesn't matter whether the node was
    # added, deleted or modified - the tile will need updating anyway.
    doc.find('//node').each do |node|
      lat = node['lat'].to_f
      if lat < -85
        lat = -85
      end
      if lat > 85
        lat = 85
      end
      point = Proj4::Point.new(Math::PI * node['lon'].to_f / 180,
                               Math::PI * lat / 180)
      nodes[node['id'].to_i] = tile_from_latlon(point, max_zoom)
    end

    # now we look for all the ways that have changed and put all of their nodes into
    # the hash too. this will add too many nodes, as it is possible a long way will be
    # changed at only a portion of its length. however, due to the non-local way that
    # mapnik does text placement, it may stil not be enough.
    #
    # also, we miss cases where nodes are deleted from ways where that node is not
    # itself deleted and the coverage of the point set isn't enough to encompass the
    # change.
    node_cache = NodeCache.new(NODE_CACHE_FILE)
    doc.find('//way/nd').each do |node|
      node_id = node['ref'].to_i

      next if nodes.include? node_id

      # this is a node referenced but not added, modified or deleted, so it should
      # still be in the node cache.
      if entry = node_cache[node_id]
        point = Proj4::Point.new(entry.lon, entry.lat)
        nodes[node_id] = tile_from_merc(point, max_zoom)
      end
    end

    # create a set of all the tiles at the maximum zoom level which are touched by
    # any of the nodes we've collected. we'll create the tiles at other zoom levels
    # by a simple recursion.
    set = Set.new nodes.values

    # expire tiles and shrink to the set of parents
    (max_zoom).downto(min_zoom) do |_|
      # allow the block to work on the set, returning the set at the next
      # zoom level
      set = yield set
    end
  end

  # wrapper to access the osm2pgsql node cache
  class NodeCache
    # node cache entry
    class Node
      attr_reader :lon, :lat

      def initialize(lon, lat)
        @lat = lat.to_f / 100.0
        @lon = lon.to_f / 100.0
      end
    end

    # open the cache
    def initialize(filename)
      @cache = Mmap.new(filename)

      throw "Unexpected format" unless @cache[0..3].unpack("l").first == 1
      throw "Unexpected ID size" unless @cache[4..7].unpack("l").first == 8

      @max_id = @cache[8..15].unpack("q").first
    end

    # lookup a node
    def [](id)
      if id <= @max_id
        offset = 16 + id * 8

        lon, lat = @cache[offset..offset + 7].unpack("ll")

        if lon != -2147483648 && lat != -2147483648
          node = Node.new(lon, lat)
        end
      end

      node
    end
  end
end
