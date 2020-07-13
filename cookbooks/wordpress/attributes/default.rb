# Enable the "wordpress" role
default[:accounts][:users][:wordpress][:status] = :role

# Set wordpress defaults
default[:wordpress][:user] = "wordpress"
default[:wordpress][:group] = "wordpress"
default[:wordpress][:sites] = {}
