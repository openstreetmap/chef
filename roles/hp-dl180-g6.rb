name "hp-dl180-g6"
description "Role applied to all HP DL180 G6 machines"

default_attributes(
  :hardware => {
    :blacklisted_modules => %w[acpi_power_meter]
  },
  :munin => {
    :plugins => {
      :hpasmcli2_fans => {
        :fan1 => { :warning => "98", :critical => "100" },
        :fan2 => { :warning => "98", :critical => "100" },
        :fan3 => { :warning => "98", :critical => "100" },
        :fan4 => { :warning => "98", :critical => "100" }
      },
      :hpasmcli2_temp => {
        :temp3 => { :warning => "80.0", :critical => "85" }
      },
      :ipmi_temp => {
        :Temp1 => { :label => "Air Inlet" },
        :Temp2CPU1 => { :warning => ":", :label => "CPU 1" },
        :Temp3CPU2 => { :warning => ":", :label => "CPU 2" },
        :Temp4 => { :warning => ":", :label => "Memory 1" },
        :Temp5 => { :warning => ":", :label => "Memory 2" },
        :Temp8MemB0 => { :warning => ":", :label => "Memory 3" },
        :Temp9MemB0 => { :warning => ":", :label => "Memory 4" },
        :Temp10MemB0 => { :warning => ":", :label => "Memory 5" },
        :Temp12MemB1 => { :warning => ":", :label => "Memory 6" },
        :Temp13MemB1 => { :warning => ":", :label => "Memory 7" },
        :Temp14MemB1 => { :warning => ":", :label => "Memory 8" },
        :Temp15 => { :warning => ":", :label => "Main System Board 3" },
        :Temp16 => { :warning => ":", :label => "Main System Board 4" },
        :Temp17 => { :warning => ":", :label => "Main System Board 5" },
        :Temp18 => { :warning => ":", :label => "Main System Board 6" },
        :Temp19 => { :warning => ":", :label => "Main System Board 7" },
        :Temp20 => { :warning => ":", :label => "Main System Board 8" },
        :Temp21 => { :warning => ":", :label => "Main System Board 9" },
        :Temp26 => { :warning => ":", :label => "Drive Backplane 1" },
        :Temp27 => { :warning => ":", :label => "Drive Backplane 2" },
        :Temp28 => { :warning => ":", :label => "Drive Backplane 3" },
        :Temp29 => { :warning => ":", :label => "Drive Backplane 4" },
        :Temp30 => { :warning => ":", :label => "Drive Backplane 5" },
        :Temp31 => { :warning => ":", :label => "Drive Backplane 6" }
      }
    }
  }
)
