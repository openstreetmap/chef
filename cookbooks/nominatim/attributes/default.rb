default[:nominatim][:state] = "off" # or: standalone, master, slave
default[:nominatim][:dbadmins] = []
default[:nominatim][:dbcluster] = "12/main"
default[:nominatim][:dbname] = "nominatim"
default[:nominatim][:tablespaces] = []
default[:nominatim][:postgis] = "2.5"
default[:nominatim][:logdir] = "/var/log/nominatim"
default[:nominatim][:repository] = "https://git.openstreetmap.org/public/nominatim.git"
default[:nominatim][:revision] = "master"
default[:nominatim][:enable_backup] = false
default[:nominatim][:enable_git_updates] = true
default[:nominatim][:enable_qa_tiles] = false
default[:nominatim][:ui_repository] = "https://git.openstreetmap.org/public/nominatim-ui.git"
default[:nominatim][:ui_revision] = "master"
default[:nominatim][:qa_repository] = "https://github.com/osm-search/Nominatim-Data-Analyser"
default[:nominatim][:qa_revision] = "main"

default[:nominatim][:fpm_pools] = {
  "nominatim.openstreetmap.org" => {
    :pm => "dynamic",
    :max_children => 60,
    :prometheus_port => 9253
  }
}

default[:nominatim][:config] = {
  :tokenizer => "icu"
}

default[:nominatim][:redirects] = {}

default[:postgresql][:versions] |= [node[:nominatim][:dbcluster].split("/").first]

default[:accounts][:users][:nominatim][:status] = :role
