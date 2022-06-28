default[:ruby][:version] = if node[:lsb][:release].to_f < 20.04
                             "2.5"
                           else
                             "2.7"
                           end
default[:ruby][:bundle] = "/usr/bin/bundle#{node[:ruby][:version]}"
