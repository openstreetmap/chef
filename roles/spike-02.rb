name "spike-02"
description "Master role applied to spike-02"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.100",
        :hwaddress => "00:1b:78:04:a5:5a"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:219:bbff:fe39:3d9e",
        :hwaddress => "00:1b:78:04:a5:5a"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[hp-g6]",
  "role[web-frontend]"
)
