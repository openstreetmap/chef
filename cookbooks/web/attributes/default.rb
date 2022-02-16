default[:web][:base_directory] = "/srv/www.openstreetmap.org"
default[:web][:pid_directory] = "/run/web"
default[:web][:log_directory] = "/var/log/web"
default[:web][:primary_cluster] = false
default[:web][:max_request_area] = 0.25
default[:web][:max_number_of_nodes] = 50000
default[:web][:max_number_of_way_nodes] = 2000
default[:web][:max_number_of_relation_members] = 32000

default[:accounts][:users][:rails][:status] = :role
