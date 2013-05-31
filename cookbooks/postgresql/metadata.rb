maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures postgresql"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"
depends           "chef"

attribute "postgresql",
  :display_name => "PostgreSQL",
  :description => "Hash of PostgreSQL configuration details",
  :type => "hash"

attribute "postgresql/versions",
  :display_name => "Versions",
  :description => "List of versions to install",
  :type => "array",
  :default => []
