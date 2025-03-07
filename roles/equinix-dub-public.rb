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
          :gateway => "184.104.226.97",
          :rules => [
            { :to => "10.0.0.0/8", :table => "main", :priority => 50 },
            { :to => "172.16.0.0/12", :table => "main", :priority => 50 },
            { :to => "192.168.0.0/16", :table => "main", :priority => 50 }
          ]
        },
        :inet6 => {
          :prefix => 64,
          :gateway => "2001:470:1:b3b::1",
          :rules => [
            { :to => "2600:9000::/28", :table => 150, :priority => 100 }
          ]
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
