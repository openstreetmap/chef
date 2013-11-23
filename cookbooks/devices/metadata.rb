name              "devices"
maintainer       "Tom Hughes"
maintainer_email "tom@compton.nu"
license          "Apache 2.0"
description      "Configures devices"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

attribute "devices",
  :display_name => "Kernel Parameters",
  :description => "Hash of devices",
  :type => "hash"
