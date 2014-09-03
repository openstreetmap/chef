name "spike-03"
description "Master role applied to spike-03"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.171",
        :hwaddress => "00:19:bb:39:8a:bc"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.103",
        :hwaddress => "00:19:bb:39:8a:ba"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:219:bbff:fe39:8aba",
        :hwaddress => "00:19:bb:39:8a:ba"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[hp-g6]",
  "role[web-frontend]"
)
