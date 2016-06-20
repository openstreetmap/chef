default[:web][:base_directory] = "/srv/www.openstreetmap.org"
default[:web][:pid_directory] = "/var/run/web"
default[:web][:log_directory] = "/var/log/web"

# need the APT source for cgimap to be able to install the package
default[:apt][:sources] = node[:apt][:sources] | ["openstreetmap-cgimap"]
