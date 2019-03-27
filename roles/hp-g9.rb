name "hp-g9"
description "Role applied to all HP G9 machines"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp11 => { :warning => 85, :critical => 100 },
        :temp12 => { :warning => 85, :critical => 100 },
        :temp19 => { :warning => 85, :critical => 100 },
        :temp20 => { :warning => 85, :critical => 100 }
      }
    }
  }
)
