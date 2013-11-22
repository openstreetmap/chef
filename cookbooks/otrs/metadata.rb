maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures OTRS"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"
depends           "apache"
depends           "postgresql"
depends           "tools"

attribute "otrs",
  :display_name => "OTRS",
  :description => "Hash of OTRS attributes",
  :type => "hash"

attribute "otrs/version",
  :display_name => "OTRS Version",
  :description => "Version of OTRS to use",
  :default => "3.1.5"

attribute "otrs/user",
  :display_name => "User",
  :description => "Iser to run OTRS as",
  :default => "otrs"

attribute "otrs/group",
  :display_name => "Group",
  :description => "Group to run OTRS as",
  :default => nil

attribute "otrs/database_cluster",
  :display_name => "Database Cluster",
  :description => "Database cluster to run OTRS against",
  :default => "8.4/main"

attribute "otrs/database_name",
  :display_name => "Database Name",
  :description => "Database to run OTRS against",
  :default => "otrs"

attribute "otrs/database_user",
  :display_name => "Database User",
  :description => "User for OTRS to connect to the database as",
  :default => "otrs"

attribute "otrs/database_password",
  :display_name => "Database Password",
  :description => "Password for OTRS to authenticate to the database with",
  :default => ""

attribute "otrs/site",
  :display_name => "Site",
  :description => "Name of OTRS site",
  :default => nil
