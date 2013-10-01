name "konqi"
description "Master role applied to konqi"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.104"
      },
      :external_ipv4_alias => {
        :interface => "eth0:1",
        :family => :inet,
        :address => "193.63.75.105",
	:prefix => "27"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:215:60ff:feaa:9956"
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :search => [ "ic.openstreetmap.org", "openstreetmap.org" ],
  }
)

run_list(
  "role[ic]"
)
