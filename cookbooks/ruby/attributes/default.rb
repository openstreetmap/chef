default[:ruby][:version] = "3.4"
default[:ruby][:interpreter] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/ruby"
default[:ruby][:gem] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/gem"
default[:ruby][:bundle] = "/usr/lib/fullstaq-ruby/versions/#{node[:ruby][:version]}-jemalloc/bin/bundle"
