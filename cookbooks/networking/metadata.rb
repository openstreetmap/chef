maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Configures networking"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe            "networking", "Configures networking via attributes"
supports          "ubuntu"

attribute "networking",
  :display_name => "Networking",
  :description => "Hash of networking attributes",
  :type => "hash"

attribute "networking/search",
  :display_name => "Resolver Search Path",
  :description => "List of domains to search",
  :default => "domain"

attribute "networking/nameservers",
  :display_name => "Nameservers",
  :description => "List of nameservers to use",
  :type => "array",
  :default => [""]

