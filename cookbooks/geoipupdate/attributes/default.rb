default[:geoipupdate][:account] = "149244"
default[:geoipupdate][:editions] = %w[GeoLite2-ASN GeoLite2-City GeoLite2-Country]
default[:geoipupdate][:directory] = if node[:lsb][:release].to_f < 22.04
                                      "/usr/share/GeoIP"
                                    else
                                      "/var/lib/GeoIP"
                                    end

default[:apt][:sources] |= ["maxmind"]
