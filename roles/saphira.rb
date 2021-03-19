name "saphira"
description "Master role applied to saphira"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "185.73.44.30",
        :prefix => "22",
        :gateway => "185.73.44.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:ba8:0:2c1e::",
        :prefix => "64",
        :gateway => "fe80::fcff:ffff:feff:ffff"
      }
    }
  }
)

run_list(
  "role[jump]",
  "role[geodns]"
)
