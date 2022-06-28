# Default to enabling the "wiki" role
default[:accounts][:users][:wiki][:status] = :role

# Set mediawiki defaults
default[:mediawiki][:user] = "wiki"
default[:mediawiki][:group] = "wiki"
default[:mediawiki][:sites] = {}
