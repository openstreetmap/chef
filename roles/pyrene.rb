name "pyrene"
description "Master role applied to pyrene"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp15 => { :warning => "59.5", :critical => "70" },
        :temp17 => { :warning => "59.5", :critical => "70" }
      },
      :hpasmcli2_fans => {
        :fan1 => { :warning => "95", :critical => "100" },
        :fan2 => { :warning => "95", :critical => "100" },
        :fan3 => { :warning => "95", :critical => "100" },
        :fan4 => { :warning => "95", :critical => "100" },
        :fan5 => { :warning => "95", :critical => "100" },
        :fan6 => { :warning => "95", :critical => "100" },
        :fan7 => { :warning => "95", :critical => "100" },
        :fan8 => { :warning => "95", :critical => "100" }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external => {
        :interface => "eno1",
        :role => :external,
        :inet => {
          :address => "140.211.167.98"
        },
        :inet6 => {
          :address => "2605:bc80:3010:700::8cd3:a762"
        }
      }
    }
  }
)

run_list(
  "role[osuosl]"
)
