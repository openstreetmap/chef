default[:glitchtip][:database_cluster] = "18/main"
default[:glitchtip][:database_name] = "glitchtip"
default[:glitchtip][:database_user] = "glitchtip"
default[:glitchtip][:database_password] = "database"

default[:postgresql][:versions] |= %w[18]
default[:postgresql][:settings][:defaults][:listen_addresses] = "*"
default[:postgresql][:settings][:defaults][:late_authentication_rules] = [
  { :database => "glitchtip", :user => "glitchtip", :address => "10.88.0.0/16" }
]

default[:valkey][:bind] |= ["10.88.0.1"]
default[:valkey][:acls] |= [
  { :user => "glitchtip", :rules => %w[+@all -DEBUG ~* &*] }
]
