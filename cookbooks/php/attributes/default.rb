default[:php][:version] = if platform?("debian")
                            case node[:platform_version].to_i
                            when 13
                              "8.4"  # PHP version for Debian 13 Trixie
                            end
                          elsif platform?("ubuntu")
                            case node[:lsb][:release].to_f
                            when 22.04
                              "8.1"  # PHP version for Ubuntu 22.04
                            when 20.04
                              "7.4"  # PHP version for Ubuntu 20.04
                            end
                          end

default[:php][:fpm][:options] = {}
