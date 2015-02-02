name              "exim"
maintainer        "OpenStreetMap Administrators"
maintainer_email  "admins@openstreetmap.org"
license           "Apache 2.0"
description       "Installs and configures exim"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
depends           "networking"

attribute "exim",
  :display_name => "Exim",
  :description => "Hash of exim attributes",
  :type => "hash"

attribute "exim/local_domains",
  :display_name => "Domains to Handle Locally",
  :description => "List of domains we are prepared to accept mail for",
  :default => [ "@" ]

attribute "exim/relay_to_domains",
  :display_name => "Domains to Relay To",
  :description => "List of domains we are prepared to relay to",
  :default => [ ]

attribute "exim/relay_from_hosts",
  :display_name => "Hosts to Relay From",
  :description => "List of hosts we are prepared to relay from",
  :default => [ "127.0.0.1", "::1" ]

attribute "exim/daemon_smtp_ports",
  :display_name => "Ports to Listen On",
  :description => "List of ports we will listen on",
  :default => [ 25 ]

attribute "exim/trusted_users",
  :display_name => "Trusted Users",
  :description => "List of users we will trust",
  :default => [ ]

attribute "exim/smarthost_name",
  :display_name => "Smarthost Name",
  :description => "Name of this smarthost",
  :default => nil

attribute "exim/smarthost_via",
  :display_name => "Smarthost Via",
  :description => "Smarthost to use for sending mail",
  :default => "mail.openstreetmap.org:26"

attribute "exim/routes",
  :display_name => "Custom Routes",
  :description => "Custom routes for handling local mail",
  :default => {}

attribute "exim/aliases",
  :display_name => "Mail Aliases",
  :description => "Mail aliases",
  :default => {}
