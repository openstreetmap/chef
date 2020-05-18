# Enable the "forum" role
default[:accounts][:users][:forum][:status] = :role

# Use prefork as PHP is to dumb for anything else
override[:apache][:mpm] = "prefork"
