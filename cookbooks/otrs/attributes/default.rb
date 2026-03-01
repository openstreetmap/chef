default[:otrs][:user] = "otrs"
default[:otrs][:group] = nil
default[:otrs][:database_cluster] = "16/main"
default[:otrs][:database_name] = "otrs"
default[:otrs][:database_user] = "otrs"
default[:otrs][:database_password] = "otrs"
default[:otrs][:site] = "otrs"

default[:postgresql][:versions] |= ["16"]
