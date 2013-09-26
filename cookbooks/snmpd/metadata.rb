maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Configures snmpd"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "networking"

attribute "snmpd",
  :display_name => "snmpd",
  :description => "Hash of snmpd attributes",
  :type => "hash"

attribute "snmpd/clients",
  :display_name => "snmpd",
  :description => "Array of addresses allowed to query snmpd",
  :type => "array"
