name              "sysctl"
maintainer       "Tom Hughes"
maintainer_email "tom@compton.nu"
license          "Apache 2.0"
description      "Configures kernel parameters"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
%w{redhat centos debian ubuntu}.each do |os|
  supports os
end
recipe           "sysctl", "Configure kernel parameters"

attribute "sysctl",
  :display_name => "Kernel Parameters",
  :description => "Hash of kernel parameter groups",
  :type => "hash"
