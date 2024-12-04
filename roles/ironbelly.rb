name "ironbelly"
description "Master role applied to ironbelly"

default_attributes(
  :elasticsearch => {
    :cluster => {
      :routing => {
        :allocation => {
          :disk => {
            :watermark => {
              :low => "95%",
              :high => "98%",
              :flood_stage => "99%"
            }
          }
        }
      }
    },
    :path => {
      :data => "/store/elasticsearch"
    }
  },
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.10"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[enp2s0f0 enp2s0f1]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.138"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::a"
        }
      }
    }
  },
  :nginx => {
    :cache => {
      :proxy => {
          :enable => true,
          :keys_zone => "proxy_cache_zone:256M",
          :inactive => "180d",
          :max_size => "51200M"
      }
    }
  }
)

run_list(
  "role[equinix-ams]",
  "recipe[rsyncd]"
)
