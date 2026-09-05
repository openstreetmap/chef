default[:valkey][:bind] = ["127.0.0.1", "::1"]
default[:valkey][:acls] = [
  { :user => "default", :rules => %w[+@all ~* &*] }
]
