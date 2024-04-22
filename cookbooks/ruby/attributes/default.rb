default[:ruby][:version] = if platform?("debian")
                             "3.1"  # ruby version for Debian
                           elsif platform?("ubuntu")
                             case node[:lsb][:release].to_f
                             when 24.04
                               "3.2"  # ruby version for Ubuntu 24.04
                             when 22.04
                               "3.0"  # ruby version for Ubuntu 22.04
                             when 20.04
                               "2.7"  # ruby version for Ubuntu 20.04
                             end
                           end

default[:ruby][:gem] = "/usr/bin/gem#{node[:ruby][:version]}"
default[:ruby][:bundle] = "/usr/bin/bundle#{node[:ruby][:version]}"
