default[:web][:base_directory] = "/srv/www.openstreetmap.org"
default[:web][:pid_directory] = "/run/web"
default[:web][:log_directory] = "/var/log/web"
default[:web][:primary_cluster] = false

default[:accounts][:users][:rails][:status] = :role
