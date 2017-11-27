name "eustace"
description "Master role applied to eustace"

default_attributes(
  :chef => {
    :client => {
      :version => "13.6.4"
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.9"
      },
      :external_ipv4 => {
        :interface => "eth0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.14"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[hp-dl360-g6]",
  "role[piwik]"
)
