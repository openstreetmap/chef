default[:php][:version] = if node[:lsb][:release].to_f < 22.04
                            "7.4"
                          else
                            "8.1"
                          end
default[:php][:fpm][:options] = {}
