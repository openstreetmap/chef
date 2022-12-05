name "tyan-s7010"
description "Role applied to machines using the Tyan S7010 motherboard"

default_attributes(
  :hardware => {
    :hwmon => {
      "i2c_0_0_002f" => {
        :ignore => %w[fan3 fan4 fan5 fan6 fan7 fan8 fan9 fan10 fan11 fan12]
      }
    },
    :ipmi => {
      :excluded_sensors => [13, 14, 15, 16, 17, 18, 19, 20]
    },
    :modules => %w[i2c_i801 jc42 w83793],
    :sensors => {
      "jc42-*" => {
        :temps => {
          "temp1" => { :max => 75 }
        }
      },
      "w83793-i2c-*-2f" => {
        :volts => {
          "in0" => { :min => 0.696, :max => 1.424 },
          "in1" => { :min => 0.696, :max => 1.424 },
          "in5" => { :min => 2.992, :max => 3.536 },
          "in9" => { :min => 2.608, :max => 3.536 }
        },
        :fans => {
          "fan1" => { :min => 1500 },
          "fan2" => { :min => 1500 },
          "fan3" => { :ignore => true },
          "fan4" => { :ignore => true },
          "fan5" => { :ignore => true },
          "fan6" => { :ignore => true },
          "fan7" => { :ignore => true },
          "fan8" => { :ignore => true },
          "fan9" => { :ignore => true },
          "fan10" => { :ignore => true },
          "fan11" => { :ignore => true },
          "fan12" => { :ignore => true }
        },
        :temps => {
          "temp5" => { :max => 78, :max_hyst => 73 },
          "temp6" => { :max => 78, :max_hyst => 73 }
        }
      }
    }
  }
)
