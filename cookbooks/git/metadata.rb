maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures git"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "1.0.0"
depends           "networking"
depends           "xinetd"
depends           "apache"

attribute "git",
  :display_name => "Git",
  :description => "Hash of Git attributes",
  :type => "hash"

attribute "git/host",
  :display_name => "Server Hostname",
  :description => "Hostname to use for Git server"

attribute "git/directory",
  :display_name => "Repository Directory",
  :description => "Directory to use for Git server repositories"
