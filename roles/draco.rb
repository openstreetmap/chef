name "draco"
description "Master role applied to draco"

default_attributes(
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "enp3s0f0.2801",
        :role => :internal,
        :inet => {
          :address => "10.0.0.11"
        }
      },
      :external => {
        :interface => "enp3s0f0.2800",
        :role => :external,
        :inet => {
          :address => "193.60.236.12"
        }
      }
    }
  }
)

run_list(
  "role[ucl]"
)
