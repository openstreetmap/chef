# Default to enabling the "wiki" role
default[:accounts][:users][:wiki][:status] = :role

# Use prefork as PHP is to dumb for anything else
default[:apache][:mpm] = "prefork"

# Set mediawiki defaults
default[:mediawiki][:user] = "wiki"
default[:mediawiki][:group] = "wiki"
default[:mediawiki][:sites] = {}

