name              "rsyncd"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Configures rsyncd"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "networking"

attribute "rsyncd",
  :display_name => "rsyncd",
  :description => "Hash of rsyncd attributes",
  :type => "hash"

attribute "rsyncd/modules",
  :display_name => "rsyncd",
  :description => "Hash of rsyncd modules to configure",
  :type => "hash"
