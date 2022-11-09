name "palulukon"
description "Master role applied to palulukon"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens5",
        :role => :external,
        :family => :inet,
        :address => "172.31.37.101",
        :prefix => "20",
        :gateway => "172.31.32.1",
        :public_address => "3.144.0.72"
      }
    }
  }
)

override_attributes(
  :networking => {
    :nameservers => ["172.31.0.2"]
  }
)

run_list(
  "role[aws-us-east-2]"
)
