default[:nominatim][:dbadmins] = []
default[:nominatim][:dbcluster] = "17/main"
default[:nominatim][:dbname] = "nominatim"
default[:nominatim][:postgis] = "3"
default[:nominatim][:logdir] = "/var/log/nominatim"
default[:nominatim][:pip_index] = "https://nominatim.org/data/osm-production"
default[:nominatim][:enable_qa_tiles] = false
default[:nominatim][:ui_repository] = "https://git.openstreetmap.org/public/nominatim-ui.git"
default[:nominatim][:ui_revision] = "master"
default[:nominatim][:qa_repository] = "https://github.com/osm-search/Nominatim-Data-Analyser"
default[:nominatim][:qa_revision] = "deploy"
default[:nominatim][:api_workers]["nominatim"] = 8
default[:nominatim][:api_workers]["nominatim_fastlane"] = 2
default[:nominatim][:api_pool_size] = 10
default[:nominatim][:api_query_timeout] = 5
default[:nominatim][:api_request_timeout] = 20

default[:nominatim][:config] = {
  :tokenizer => "icu"
}

default[:postgresql][:versions] |= [node[:nominatim][:dbcluster].split("/").first]
default[:postgresql][:monitor_database] = "nominatim"

default[:accounts][:users][:nominatim][:status] = :role
