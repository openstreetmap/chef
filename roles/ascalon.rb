name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eno1",
        :role => :external,
        :family => :inet,
        :address => "184.107.48.228",
        :prefix => "27",
        :gateway => "184.107.48.225"
      }
    }
  }
)

run_list(
  "role[netalerts]"
)
