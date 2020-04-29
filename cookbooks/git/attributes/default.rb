default[:git][:host] = "git.openstreetmap.org"
default[:git][:directory] = "/var/lib/git"
default[:git][:public_user] = "git"
default[:git][:public_group] = "git"
default[:git][:private_user] = "git"
default[:git][:private_group] = "git"
default[:git][:private_nodes] = "fqdn:*"

default[:apt][:sources] |= ["git-core"]
