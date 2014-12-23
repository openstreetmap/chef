name "hp-g5"
description "Role applied to all HP G5 machines"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp1 => { :warning => 60 }
      }
    }
  }
)
