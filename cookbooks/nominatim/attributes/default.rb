default[:nominatim][:state] = "off" # or: standalone, master, slave
default[:nominatim][:dbadmins] = []
default[:nominatim][:dbname] = "nominatim"
default[:nominatim][:tablespaces] = []
default[:nominatim][:logdir] = "/var/log/nominatim"
default[:nominatim][:repository] = "https://git.openstreetmap.org/public/nominatim.git"
default[:nominatim][:revision] = "master"
default[:nominatim][:enable_backup] = false
default[:nominatim][:enable_git_updates] = true

default[:nominatim][:fpm_pools] = {
  :www => {
    :port => "8000",
    :pm => "dynamic",
    :max_children => "60"
  }
}

default[:nominatim][:redirects] = {}
