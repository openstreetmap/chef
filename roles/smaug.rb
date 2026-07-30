name "smaug"
description "Master role applied to smaug"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :inet => {
          :address => "10.0.64.14"
        },
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno5 eno6]
        }
      },
      :henet => {
        :inet => {
          :address => "184.104.226.110"
        },
        :inet6 => {
          :address => "2001:470:1:b3b::e"
        }
      },
      :equinix => {
        :inet => {
          :address => "87.252.214.110"
        },
        :inet6 => {
          :address => "2001:4d78:fe03:1c::e"
        }
      }
    }
  }
)

run_list(
  "role[equinix-dub-public]",
  "role[matomo]"
)
