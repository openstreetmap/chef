default[:ruby][:fullstaq] = false

if node[:ruby][:fullstaq]

  default[:ruby][:version] = "3.4"
  default[:ruby][:interpreter] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/ruby"
  default[:ruby][:gem] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/gem"
  default[:ruby][:bundle] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/bundle"

else

  default[:ruby][:version] = if platform?("debian")
                               "3.1"
                             elsif node[:lsb][:release].to_f < 22.04
                               "2.7"
                             else
                               "3.0"
                             end
  default[:ruby][:interpreter] = "/usr/bin/ruby#{node[:ruby][:version]}"
  default[:ruby][:gem] = "/usr/bin/gem#{node[:ruby][:version]}"
  default[:ruby][:bundle] = "/usr/bin/bundle#{node[:ruby][:version]}"

end
