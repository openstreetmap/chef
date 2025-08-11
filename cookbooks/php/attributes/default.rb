default[:php][:version] = if platform?("debian")
                            if node[:platform_version].to_i >= 13
                              "8.4"
                            else
                              "8.2"
                            end
                          elsif node[:lsb][:release].to_f < 22.04
                            "7.4"
                          else
                            "8.1"
                          end
default[:php][:fpm][:options] = {}
