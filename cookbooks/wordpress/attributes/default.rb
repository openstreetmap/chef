# Enable the "wordpress" role
default[:accounts][:users][:wordpress][:status] = :role

# Use prefork as PHP is to dumb for anything else
default[:apache][:mpm] = "prefork"

# Make sure httpclient and php_serialize are installed
default[:chef][:gems] |= %w(httpclient php_serialize)

# Set wordpress defaults
default[:wordpress][:user] = "wordpress"
default[:wordpress][:group] = "wordpress"
default[:wordpress][:sites] = {}
