default[:ruby][:fullstaq] = true

default[:ruby][:system_version] = if platform?("debian")
                                    if node[:platform_version].to_i >= 13
                                      "3.3"
                                    else
                                      "3.1"
                                    end
                                  elsif node[:lsb][:release].to_f < 22.04
                                    "2.7"
                                  else
                                    "3.0"
                                  end
default[:ruby][:system_interpreter] = "/usr/bin/ruby#{node[:ruby][:system_version]}"
default[:ruby][:system_gem] = "/usr/bin/gem#{node[:ruby][:system_version]}"
default[:ruby][:system_bundle] = "/usr/bin/bundle#{node[:ruby][:system_version]}"

if node[:ruby][:fullstaq]

  default[:ruby][:version] = "3.4"
  default[:ruby][:interpreter] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/ruby"
  default[:ruby][:gem] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/gem"
  default[:ruby][:bundle] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/bundle"

else

  default[:ruby][:version] = node[:ruby][:system_version]
  default[:ruby][:interpreter] = node[:ruby][:system_interpreter]
  default[:ruby][:gem] = node[:ruby][:system_gem]
  default[:ruby][:bundle] = node[:ruby][:system_bundle]

end
