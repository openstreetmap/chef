name              "dhcpd"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Configures dhcpd"
long_description  IO.read(File.join(File.dirname(__FILE__), "README.md"))
version           "1.0.0"
depends           "networking"

attribute "dhcpd",
  :display_name => "dhcpd",
  :description => "Hash of dhcpd attributes",
  :type => "hash"
