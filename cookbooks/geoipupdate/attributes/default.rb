default[:geoipupdate][:account] = "149244"
default[:geoipupdate][:editions] = %w[GeoLite2-ASN GeoLite2-City GeoLite2-Country]

default[:apt][:sources] |= ["maxmind"]
