name "meraxes"
description "Master role applied to meraxes"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "enp1s0f0",
        :role => :external,
        :inet => {
          :address => "51.15.185.90",
          :prefix => "24",
          :gateway => "51.15.185.1"
        },
        :inet6 => {
          :address => "2001:bc8:2d57:100:aa1e:84ff:fe72:e660",
          :prefix => "48",
          :gateway => "2001:bc8:2::2:258:1",
          :dhcp => {
            :duidtype => "link-layer",
            :duidrawdata => "00:01:14:e9:19:1c:49:e0"
          }
        }
      }
    }
  }
)

run_list(
  "role[scaleway]"
)
