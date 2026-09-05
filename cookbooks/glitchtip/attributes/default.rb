default[:glitchtip][:database_cluster] = "18/main"
default[:glitchtip][:database_name] = "glitchtip"
default[:glitchtip][:database_user] = "glitchtip"
default[:glitchtip][:database_password] = "database"

default[:postgresql][:versions] |= %w[18]
default[:postgresql][:default][:listen_addresses] = "10.88.0.1"
default[:postgresql][:default][:late_authentication_rules] = [
  { :database => "glitchtip", :user => "glitchtip", :address => "10.88.0.0/16" }
]
