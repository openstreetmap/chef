default[:osqa][:user] = "osqa"
default[:osqa][:group] = nil
default[:osqa][:database_cluster] = "15/main"
default[:osqa][:database_name] = "osqa"
default[:osqa][:database_user] = "osqa"
default[:osqa][:database_password] = ""
default[:osqa][:sites] = []

default[:postgresql][:versions] |= ["15"]

default[:accounts][:users][:osqa][:status] = :role
