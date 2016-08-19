default[:nominatim][:state] = "off" # or: standalone, master, slave
default[:nominatim][:dbadmins] = []
default[:nominatim][:dbname] = "nominatim"
default[:nominatim][:tablespaces] = []
default[:nominatim][:logdir] = "/var/log/nominatim"
default[:nominatim][:repository] = "git://git.openstreetmap.org/nominatim.git"
default[:nominatim][:revision] = "master"
default[:nominatim][:enable_backup] = false

default[:nominatim][:fpm_pools] = {
  :www => {
    :port => "8000",
    :pm => "dynamic",
    :max_children => "60"
  },
  :bulk => {
    :port => "8001",
    :pm => "static",
    :max_children => "10"
  },
  :details => {
    :port => "8002",
    :pm => "static",
    :max_children => "2"
  }
}

default[:nominatim][:redirects] = {}
