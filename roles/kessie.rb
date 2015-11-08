name "kessie"
description "Master role applied to kessie"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "em1",
        :role => :external,
        :family => :inet,
        :address => "10.42.0.98",
        :hwaddress => "d8:d3:85:5d:87:5e",
        :prefix => "24",
        :gateway => "10.42.0.1"
      }
    },
    :nameservers => ["10.42.0.1"]
  }
)

run_list(
  "role[exonetric]",
  "role[hp-dl180-g6]"
)
