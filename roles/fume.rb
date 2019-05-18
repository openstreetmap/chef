name "fume"
description "Master role applied to fume"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "147.228.60.16",
        :prefix => "24",
        :gateway => "147.228.60.1"
      }
    }
  }
)

run_list(
  "role[zcu]"
)
