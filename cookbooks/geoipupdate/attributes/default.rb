default[:geoipupdate][:account] = "149244"
default[:geoipupdate][:editions] = %w[GeoLite2-ASN GeoLite2-City GeoLite2-Country]
default[:geoipupdate][:directory] = if platform?("debian")
                                      "/var/lib/GeoIP"
                                    else
                                      "/usr/share/GeoIP"
                                    end
