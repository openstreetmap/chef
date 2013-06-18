maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Accounts management"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"

attribute "accounts",
  :display_name => "Accounts",
  :description => "Hash of account attributes",
  :type => "hash"

attribute "accounts/home",
  :display_name => "Home Directory",
  :description => "Home directory for accounts",
  :default => "/home"

attribute "accounts/shell",
  :display_name => "Default Shell",
  :description => "Default shell for accounts",
  :default => "/bin/bash"

attribute "accounts/users",
  :display_name => "Users",
  :description => "User account details",
  :type => "hash"
