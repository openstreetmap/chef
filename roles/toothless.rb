name "toothless"
description "Master role applied to toothless"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "185.73.44.167",
        :prefix => "22",
        :gateway => "185.73.44.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:ba8:0:2ca7::",
        :prefix => "64",
        :gateway => "fe80::fcff:ffff:feff:ffff"
      }
    }
  }
)

run_list(
  "role[jump]"
)
