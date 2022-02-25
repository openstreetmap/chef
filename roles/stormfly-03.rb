name "stormfly-03"
description "Master role applied to stormfly-03"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp2 => { :warning => "68" },
        :temp3 => { :warning => "68" }
      },
      :sensors_temp => {
        :temp4 => { :warning => "98" },
        :temp5 => { :warning => "98" },
        :temp6 => { :warning => "98" },
        :temp7 => { :warning => "98" },
        :temp8 => { :warning => "98" },
        :temp9 => { :warning => "98" },
        :temp10 => { :warning => "98" },
        :temp11 => { :warning => "98" },
        :temp12 => { :warning => "98" },
        :temp13 => { :warning => "98" },
        :temp14 => { :warning => "98" },
        :temp15 => { :warning => "98" },
        :temp16 => { :warning => "98" },
        :temp17 => { :warning => "98" },
        :temp21 => { :warning => "98" },
        :temp22 => { :warning => "98" },
        :temp23 => { :warning => "98" },
        :temp24 => { :warning => "98" },
        :temp25 => { :warning => "98" },
        :temp26 => { :warning => "98" },
        :temp27 => { :warning => "98" },
        :temp28 => { :warning => "98" },
        :temp29 => { :warning => "98" },
        :temp30 => { :warning => "98" },
        :temp31 => { :warning => "98" },
        :temp32 => { :warning => "98" },
        :temp33 => { :warning => "98" },
        :temp34 => { :warning => "98" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "140.211.167.99",
        :bond => {
          :slaves => %w[eno1 eno2 eno3 eno4 eno49 eno50]
        }
      },
      :external_ipv6 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet6,
        :address => "2605:bc80:3010:700::8cd3:a763"
      }
    },
    :private_address => "10.0.16.200"
  }
)

run_list(
  "role[osuosl]",
  "role[hp-g9]",
  "role[prometheus]"
)
