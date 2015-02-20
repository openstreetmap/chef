name              "bind"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Configures bind"
long_description  IO.read(File.join(File.dirname(__FILE__), "README.md"))
version           "1.0.0"
depends           "networking"

attribute "bind",
  :display_name => "bind",
  :description => "Hash of bind attributes",
  :type => "hash"

attribute "bind/forwarders",
  :display_name => "bind",
  :description => "Array of resolvers to forward to",
  :type => "array"
