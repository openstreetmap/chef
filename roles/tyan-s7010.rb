name "tyan-s7010"
description "Role applied to machines using the Tyan S7010 motherboard"

default_attributes(
  :hardware => {
    :modules => %w(i2c_i801 jc42 w83793),
    :sensors => {
      "jc42-*" => {
        :temps => {
          "temp1" => { :max => 75 },
        },
      },
      "w83793-i2c-*-2f" => {
        :volts => {
          "in0" => { :min => 0.696, :max => 1.424 },
          "in1" => { :min => 0.696, :max => 1.424 },
          "in5" => { :min => 2.992, :max => 3.536 },
          "in9" => { :min => 2.608, :max => 3.536 },
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
          "fan12" => { :ignore => true },
        },
        :temps => {
          "temp5" => { :max => 78, :max_hyst => 73 },
          "temp6" => { :max => 78, :max_hyst => 73 },
        },
      },
    },
  },
  :munin => {
    :plugins => {
      :ipmi_fans => {
        :Sys3Front1 => { :graph => "no", :warning => "0:" },
        :Sys4Front2 => { :graph => "no", :warning => "0:" },
        :Sys5Rear1 => { :graph => "no", :warning => "0:" },
        :Sys6 => { :graph => "no", :warning => "0:" },
        :Sys7 => { :graph => "no", :warning => "0:" },
        :Sys8 => { :graph => "no", :warning => "0:" },
        :Sys9 => { :graph => "no", :warning => "0:" },
        :Sys10 => { :graph => "no", :warning => "0:" },
      },
      :ipmi_temp => {
        :CPU0belowTmax => { :critical => "10:" },
        :CPU1belowTmax => { :critical => "10:" },
      },
      :sensors_volt => {
        "VCoreA" => { :warning => "0.70:1.42", :critical => "0.70:1.42" },
        "VCoreB" => { :warning => "0.70:1.42", :critical => "0.70:1.42" },
        "in2" => { :warning => "0.00:2.05", :critical => "0.00:2.05" },
        "in3" => { :warning => "0.00:4.08", :critical => "0.00:4.08" },
        "in4" => { :warning => "0.00:4.08", :critical => "0.00:4.08" },
        "in5" => { :warning => "2.99:3.54", :critical => "2.99:3.54" },
        "in6" => { :warning => "0.00:2.04", :critical => "0.00:2.04" },
        "+5V" => { :warning => "4.52:5.50", :critical => "4.52:5.50" },
        "5VSB" => { :warning => "4.52:5.50", :critical => "4.52:5.50" },
        "Vbat" => { :warning => "2.70:3.30", :critical => "2.70:3.30" },
      },
    },
  }
)
