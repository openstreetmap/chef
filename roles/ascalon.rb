name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.18"
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
  "role[ucl-wates]",
  "role[roundup]"
)
