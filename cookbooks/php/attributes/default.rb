default[:php][:version] = if platform?("debian")
                            "8.2"
                          elsif node[:lsb][:release].to_f < 22.04
                            "7.4"
                          else
                            "8.1"
                          end
default[:php][:fpm][:options] = {}
