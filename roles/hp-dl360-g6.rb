name "hp-dl360-g6"
description "Role applied to all HP DL360 G6 machines"

default_attributes(
  :munin => {
    :plugins => {
      :hpasmcli2_fans => {
        :fan1 => { :warning => "85", :critical => "90" },
        :fan2 => { :warning => "85", :critical => "90" },
        :fan3 => { :warning => "85", :critical => "90" },
        :fan4 => { :warning => "85", :critical => "90" }
      },
      :ipmi_temp => {
        :Temp1 => { :label => "External Environment" },
        :Temp2 => { :warning => ":", :label => "CPU 1" },
        :Temp3 => { :warning => ":", :label => "CPU 2" },
        :Temp4 => { :warning => ":", :label => "Memory 1" },
        :Temp5 => { :warning => ":", :label => "Memory 2" },
        :Temp6 => { :warning => ":", :label => "Memory 3" },
        :Temp7 => { :warning => ":", :label => "Memory 4" },
        :Temp8 => { :warning => ":", :label => "Memory 5" },
        :Temp9 => { :warning => ":", :label => "Memory 6" },
        :Temp10 => { :warning => ":", :label => "Memory 7" },
        :Temp11 => { :warning => ":", :label => "Memory 8" },
        :Temp12 => { :warning => ":", :label => "PSU 1" },
        :Temp13 => { :warning => ":", :label => "PSU 2" },
        :Temp14 => { :warning => ":", :label => "Memory 9" },
        :Temp15 => { :warning => ":", :label => "CPU Zone 1" },
        :Temp16 => { :warning => ":", :label => "CPU Zone 2" },
        :Temp17 => { :warning => ":", :label => "Memory 10" },
        :Temp18 => { :warning => ":", :label => "CPU Zone 3" },
        :Temp19 => { :warning => ":", :label => "Peripheral Bay 1" },
        :Temp20 => { :warning => ":", :label => "Peripheral Bay 2" },
        :Temp21 => { :warning => ":", :label => "Peripheral Bay 3" },
        :Temp22 => { :warning => ":", :label => "Peripheral Bay 4" },
        :Temp23 => { :warning => ":", :label => "Peripheral Bay 5" },
        :Temp24 => { :warning => ":", :label => "Peripheral Bay 6" },
        :Temp25 => { :warning => ":", :label => "Peripheral Bay 7" },
        :Temp26 => { :warning => ":", :label => "Peripheral Bay 8" },
        :Temp27 => { :warning => ":", :label => "Drive Backplane" },
        :Temp28 => { :warning => ":", :label => "System Board" }
      }
    }
  }
)
