name "equinix-ams-public"
description "Role applied to all public servers at Equinix Amsterdam"

default_attributes(
  :networking => {
    :interfaces => {
      :henet => {
        :interface => "bond0.3",
        :role => :external,
        :zone => "ams",
        :metric => 150,
        :source_route_table => 3,
        :inet => {
          :prefix => "27",
          :gateway => "184.104.179.129"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:470:1:fa1::1"
        }
      },
      :equinix => {
        :interface => "bond0.103",
        :role => :external,
        :zone => "ams",
        :metric => 100,
        :source_route_table => 103,
        :inet => {
          :prefix => "27",
          :gateway => "82.199.86.97"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:4d78:500:5e3::1"
        }
      }
    }
  }
)

run_list(
  "role[equinix-ams-public]"
)
