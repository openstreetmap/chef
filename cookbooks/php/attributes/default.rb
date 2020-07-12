default[:php][:version] = if node[:lsb][:release].to_f < 20.04
                            "7.2"
                          else
                            "7.4"
                          end

default[:php][:fpm][:options] = {}
