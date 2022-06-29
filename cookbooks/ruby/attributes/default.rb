default[:ruby][:version] = if node[:lsb][:release].to_f < 22.04
                             "2.7"
                           else
                             "3.0"
                           end
default[:ruby][:bundle] = "/usr/bin/bundle#{node[:ruby][:version]}"
