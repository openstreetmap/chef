name "ridley"
description "Master role applied to ridley"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :start_servers => 12,
      :server_limit => 48,
      :min_spare_threads => 25,
      :max_spare_threads => 75,
      :max_connections_per_child => 10000
    }
  },
  :dhcpd => {
    :first_address => "10.0.15.1",
    :last_address => "10.0.15.254"
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.19"
      },
      :internal_ipv4 => {
        :interface => "eth0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.3"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[hp-dl360-g6]",
  "role[gateway]",
  "role[foundation]",
  "role[stateofthemap]",
  "role[blog]",
  "role[otrs]",
  "role[donate]",
  "recipe[hot]",
  "recipe[dmca]",
  "recipe[dhcpd]",
  "recipe[ideditor]"
)
