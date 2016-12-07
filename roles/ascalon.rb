name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.18"
      },
      :external_ipv4 => {
        :interface => "eth1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.10"
      }
    }
  },
  :accounts => {
    :users => {
      :emacsen => { :status => :administrator }
    }
  }
)

run_list(
  "role[ucl-slough]",
  "role[hp-g5]",
  "role[roundup]"
)
