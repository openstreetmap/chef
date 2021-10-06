name "hp-dl360e-g8"
description "Role applied to all HP DL360e G8 machines"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_temp => {
        :temp15 => { :warning => 68, :critical => 80 },
        :temp16 => { :warning => 68, :critical => 80 }
      }
    }
  }
)
