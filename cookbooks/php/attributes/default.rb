default[:php][:version] = if platform?("debian")
                            "8.2"  # PHP version for Debian
                          elsif platform?("ubuntu")
                            case node[:lsb][:release].to_f
                            when 24.04
                              "8.3"  # PHP version for Ubuntu 24.04
                            when 22.04
                              "8.1"  # PHP version for Ubuntu 22.04
                            when 20.04
                              "7.4"  # PHP version for Ubuntu 20.04
                            end
                          end

default[:php][:fpm][:options] = {}
