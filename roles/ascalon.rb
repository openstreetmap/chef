name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.45.193"
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
  "role[ucl-wolfson]",
  "role[roundup]"
)
