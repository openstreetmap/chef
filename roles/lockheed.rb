name "lockheed"
description "Master role applied to lockheed"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :inet => {
          :address => "10.0.48.16"
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4",
          :slaves => %w[eno49 eno50]
        }
      },
      :external => {
        :interface => "bond0.3",
        :role => :external,
        :inet => {
          :address => "184.104.179.144"
        },
        :inet6 => {
          :address => "2001:470:1:fa1::10"
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
  "role[hp-g9]",
  "recipe[imagery::za_ngi_aerial]",
  "recipe[imagery::us_imagery]"
)
