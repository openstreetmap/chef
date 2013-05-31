maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures OSQA"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"
depends           "apache"
depends           "memcached"

attribute "osqa",
  :display_name => "OSQA",
  :description => "Hash of OSQA attributes",
  :type => "hash"

attribute "osqa/revision",
  :display_name => "OSQA Revision",
  :description => "Default revision of OSQA to use",
  :default => "703"

attribute "osqa/user",
  :display_name => "User",
  :description => "Default user to run OSQA as",
  :default => "osqa"

attribute "osqa/group",
  :display_name => "Group",
  :description => "Default group to run OSQA ad",
  :default => nil

attribute "osqa/database_name",
  :display_name => "Database Name",
  :description => "Default database to run OSQA against",
  :default => "osqa"

attribute "osqa/database_user",
  :display_name => "Database User",
  :description => "Default user for OSQA to connect to the database as",
  :default => "osqa"

attribute "osqa/database_password",
  :display_name => "Database Password",
  :description => "Default password for OSQA to authenticate to the database with",
  :default => ""

attribute "osqa/sites",
  :display_name => "Sites",
  :description => "Array of OSQA sites to setup",
  :default => []
