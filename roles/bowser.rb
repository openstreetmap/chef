name "bowser"
description "Master role applied to bowser"

default_attributes(
  :location => "Carlton, Victoria, Australia",
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "138.44.68.106",
        :prefix => "30",
        :gateway => "138.44.68.105",
        :mtu => 9000,
        :bond => {
          :slaves => %w[ens14f0 ens14f1]
        }
      }
    },
    :nameservers => [
      "202.158.207.1",
      "202.158.207.2"
    ]
  }
)

run_list(
  "role[aarnet]"
)
