name              "dev"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures dev services"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "apache"
depends           "git"
depends           "mysql"
depends           "postgresql"
depends           "tools"
depends           "web"

attribute "rails",
  :display_name => "Rails Configuration",
  :description => "Hash of rails port configuration information",
  :type => "hash"

attribute "rails/sites",
  :display_name => "Rails Installations",
  :description => "Hash of rails port installations to configure",
  :type => "hash"

attribute "rails/sites/repository",
  :display_name => "Repository",
  :description => "Git repository to use",
  :default => "git://git.openstreetmap.org/rails.git"

attribute "rails/sites/revision",
  :display_name => "Revision",
  :description => "Revision to use",
  :default => "live"

attribute "rails/sites/database",
  :display_name => "Database",
  :description => "Database to use",
  :default => nil
