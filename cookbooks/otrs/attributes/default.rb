default[:otrs][:version] = "6.0.48"
default[:otrs][:user] = "otrs"
default[:otrs][:group] = nil
default[:otrs][:database_cluster] = "15/main"
default[:otrs][:database_name] = "otrs"
default[:otrs][:database_user] = "otrs"
default[:otrs][:database_password] = "otrs"
default[:otrs][:site] = "otrs"

default[:postgresql][:versions] |= ["15"]

default[:accounts][:users][:otrs][:status] = :role
default[:accounts][:groups][:"www-data"][:members] = [:otrs]
