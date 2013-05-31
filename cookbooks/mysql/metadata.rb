maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures mysql"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"

attribute "mysql",
  :display_name => "MySQL",
  :description => "Hash of MySQL configuration details",
  :type => "hash"
