name "kessie"
description "Master role applied to kessie"

default_attributes(
  :sysctl => {
    :swappiness => {
      :comment => "Only swap in an emergency",
      :parameters => {
        "vm.swappiness" => "1"
      }
    }
  },
  :munin => {
    :plugins => {
      :sensors_temp => {
        :temp6 => { :warning => "71.0", :critical => "76.0" },
        :temp7 => { :warning => "71.0", :critical => "76.0" },
        :temp8 => { :warning => "71.0", :critical => "76.0" },
        :temp9 => { :warning => "71.0", :critical => "76.0" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external => {
        :interface => "enp2s0f0",
        :role => :external,
        :inet => {
          :address => "178.250.74.36"
        },
        :inet6 => {
          :address => "2a02:1658:4:0:dad3:85ff:fe5d:875e"
        }
      }
    }
  }
)

run_list(
  "role[exonetric]",
  "role[hp-dl180-g6]",
  "role[imagery]"
)
