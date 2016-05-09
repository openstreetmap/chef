# Enable the "wordpress" role
default[:accounts][:users][:wordpress][:status] = :role

# Use prefork as PHP is to dumb for anything else
default[:apache][:mpm] = "prefork"

# Set wordpress defaults
default[:wordpress][:user] = "wordpress"
default[:wordpress][:group] = "wordpress"
default[:wordpress][:sites] = {}
