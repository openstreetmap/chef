#!/usr/bin/ruby

require 'rubygems'
require 'pg'
require 'yaml'
require 'time'
require 'fileutils'
require 'xml/libxml'
require 'zlib'

# after this many changes, a changeset will be closed
CHANGES_LIMIT=50000

# this is the scale factor for lat/lon values stored as integers in the database
GEO_SCALE=10000000

##
# changeset class keeps some information about changesets downloaded from the
# database - enough to let us know which changesets are closed/open & recently
# closed.
class Changeset
  attr_reader :id, :created_at, :closed_at, :num_changes

  def initialize(row)
    @id = row['id'].to_i
    @created_at = Time.parse(row['created_at'])
    @closed_at = Time.parse(row['closed_at'])
    @num_changes = row['num_changes'].to_i
  end

  def closed?(t)
    (@closed_at < t) || (@num_changes >= CHANGES_LIMIT)
  end

  def open?(t)
    not closed?(t)
  end

  def activity_between?(t1, t2)
    ((@closed_at >= t1) && (@closed_at < t2)) || ((@created_at >= t1) && (@created_at < t2))
  end
end

##
# state and connections associated with getting changeset data
# replicated to a file.
class Replicator
  def initialize(config)
    @config = YAML.load(File.read(config))
    @state = YAML.load(File.read(@config['state_file']))
    @conn = PGconn.connect(@config['db'])
    @now = Time.now.getutc
  end

  def open_changesets
    last_run = @state['last_run']
    last_run = (@now - 60) if last_run.nil?
    @state['last_run'] = @now
    # pretty much all operations on a changeset will modify its closed_at
    # time (see rails_port's changeset model). so it is probably enough 
    # for us to look at anything that was closed recently, and filter from
    # there.
    @conn.
      exec("select id, created_at, closed_at, num_changes from changesets where closed_at > ((now() at time zone 'utc') - '1 hour'::interval)").
      map {|row| Changeset.new(row) }.
      select {|cs| cs.activity_between?(last_run, @now) }
  end

  # creates an XML file containing the changeset information from the 
  # list of changesets output by open_changesets.
  def changeset_dump(changesets)
    doc = XML::Document.new
    doc.root = XML::Node.new("osm")
    { 'version' => '0.6',
      'generator' => 'replicate_changesets.rb',
      'copyright' => "OpenStreetMap and contributors",
      'attribution' => "http://www.openstreetmap.org/copyright",
      'license' => "http://opendatacommons.org/licenses/odbl/1-0/" }.
      each { |k,v| doc.root[k] = v }

    changesets.each do |cs|
      xml = XML::Node.new("changeset")
      xml['id'] = cs.id.to_s
      xml['created_at'] = cs.created_at.getutc.xmlschema
      xml['closed_at'] = cs.closed_at.getutc.xmlschema if cs.closed?(@now)
      xml['open'] = cs.open?(@now).to_s
      xml['num_changes'] = cs.num_changes.to_s

      res = @conn.exec("select u.id, u.display_name, c.min_lat, c.max_lat, c.min_lon, c.max_lon from users u join changesets c on u.id=c.user_id where c.id=#{cs.id}")
      xml['user'] = res[0]['display_name']
      xml['uid'] = res[0]['id']

      unless (res[0]['min_lat'].nil? ||
              res[0]['max_lat'].nil? ||
              res[0]['min_lon'].nil? ||
              res[0]['max_lon'].nil?)
        xml['min_lat'] = (res[0]['min_lat'].to_f / GEO_SCALE).to_s
        xml['max_lat'] = (res[0]['max_lat'].to_f / GEO_SCALE).to_s
        xml['min_lon'] = (res[0]['min_lon'].to_f / GEO_SCALE).to_s
        xml['max_lon'] = (res[0]['max_lon'].to_f / GEO_SCALE).to_s
      end

      res = @conn.exec("select k, v from changeset_tags where changeset_id=#{cs.id}")
      res.each do |row|
        tag = XML::Node.new("tag")
        tag['k'] = row['k']
        tag['v'] = row['v']
        xml << tag
      end

      doc.root << xml
    end
    
    doc.to_s
  end

  # saves new state (including the changeset dump xml)
  def save!
    File.open(@config['state_file'], "r") do |fl|
      fl.flock(File::LOCK_EX)

      sequence = (@state.has_key?('sequence') ? @state['sequence'] + 1 : 0)
      data_file = @config['data_dir'] + sprintf("/%03d/%03d/%03d.osm.gz", sequence / 1000000, (sequence / 1000) % 1000, (sequence % 1000));
      tmp_state = @config['state_file'] + ".tmp"
      tmp_data = "/tmp/changeset_data.osm.tmp"
      # try and write the files to tmp locations and then
      # move them into place later, to avoid in-progress
      # clashes, or people seeing incomplete files.
      begin
        FileUtils.mkdir_p(File.dirname(data_file))
        Zlib::GzipWriter.open(tmp_data) do |fh|
          fh.write(changeset_dump(open_changesets))
        end
        @state['sequence'] = sequence
        File.open(tmp_state, "w") do |fh|
          fh.write(YAML.dump(@state))
        end
        FileUtils.mv(tmp_data, data_file)
        FileUtils.mv(tmp_state, @config['state_file'])
        fl.flock(File::LOCK_UN)

      rescue
        STDERR.puts("Error! Couldn't update state.")
        fl.flock(File::LOCK_UN)
        raise
      end
    end
  end
end

rep = Replicator.new(ARGV[0])
rep.save!

