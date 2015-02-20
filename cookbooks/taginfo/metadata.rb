name              "taginfo"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures taginfo"
long_description  IO.read(File.join(File.dirname(__FILE__), "README.md"))
version           "1.0.0"
depends           "apache"
depends           "passenger"
depends           "git"

attribute "taginfo",
  :display_name => "TAGINFO",
  :description => "Hash of TAGINFO attributes",
  :type => "hash"

attribute "taginfo/sites",
  :display_name => "Sites",
  :description => "Array of TAGINFO sites to setup",
  :default => []
