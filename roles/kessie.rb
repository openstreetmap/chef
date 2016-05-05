name "kessie"
description "Master role applied to kessie"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "em1",
        :role => :external,
        :family => :inet,
        :address => "178.250.74.36",
        :hwaddress => "d8:d3:85:5d:87:5e"
      }
    }
  }
)

run_list(
  "role[exonetric]",
  "role[hp-dl180-g6]",
  "role[imagery]"
)
