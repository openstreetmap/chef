name "equinix-dub-public"
description "Role applied to all public servers at Equinix Dublin"

default_attributes(
  :networking => {
    :interfaces => {
      :henet => {
        :interface => "bond0.101",
        :role => :external,
        :zone => "dub",
        :metric => 150,
        :source_route_table => 101,
        :inet => {
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :prefix => 64,
          :gateway => "2001:470:1:b3b::1",
          :routes => {
            "2600:9000::/28" => { :table => 101, :type => "unreachable" }
          }
        }
      },
      :equinix => {
        :interface => "bond0.203",
        :role => :external,
        :zone => "dub",
        :metric => 100,
        :source_route_table => 203,
        :inet => {
          :prefix => "27",
          :gateway => "87.252.214.97"
        },
        :inet6 => {
          :prefix => 64,
          :gateway => "2001:4d78:fe03:1c::1"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub]"
)
