default[:ruby][:version] = if platform?("debian")
                             "3.1"
                           elsif node[:lsb][:release].to_f < 22.04
                             "2.7"
                           else
                             "3.0"
                           end
default[:ruby][:gem] = "/usr/bin/gem#{node[:ruby][:version]}"
default[:ruby][:bundle] = "/usr/bin/bundle#{node[:ruby][:version]}"
