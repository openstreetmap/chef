default[:overpass][:fqdn] = "overpass.openstreetmap.org"
default[:overpass][:version] = "0.7.57"
# One of: no, meta, attic
default[:overpass][:meta_mode] = "attic"
# One of: no, gz, lz4
default[:overpass][:compression_mode] = "lz4"
default[:overpass][:rate_limit] = 2
default[:overpass][:dispatcher_space] = 10 * 1024 * 1024 * 1024
default[:overpass][:clone_url] = "http://dev.overpass-api.de/api_drolbr"
default[:overpass][:replication_url] = "https://planet.openstreetmap.org/replication/minute/"
# If true only provide an API for the query feature on the website
default[:overpass][:restricted_api] = true

default[:overpass][:logdir] = "/var/log/overpass"
