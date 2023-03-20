name "grindtooth"
description "Master role applied to grindtooth"

default_attributes(
  :networking => {
    :engine => "systemd-networkd",
    :interfaces => {
      :internal => {
        :interface => "enp3s0f0.2801",
        :role => :internal,
        :inet => {
          :address => "10.0.0.19"
        }
      },
      :external => {
        :interface => "enp3s0f0.2800",
        :role => :external,
        :inet => {
          :address => "193.60.236.15"
        }
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[taginfo]"
)
