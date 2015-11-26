name "dulcy"
description "Master role applied to dulcy
"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "p18p1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.109",
        :hwaddress => "0c:c4:7a:66:96:d2"
      },
      :external_ipv6 => {
        :interface => "p18p1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:ec4:7aff:fe66:96d2"
      }
    }
  }
)

run_list(
  "role[ic]"
)
