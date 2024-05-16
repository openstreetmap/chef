name "ridley"
description "Master role applied to ridley"

default_attributes(
  :accounts => {
    :users => {
      :otrs => { :status => :role }
    }
  },
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
      :external => {
        :interface => "eth0.2800",
        :role => :external,
        :inet => {
          :address => "193.60.236.19"
        }
      },
      :internal => {
        :interface => "eth0.2801",
        :role => :internal,
        :inet => {
          :address => "10.0.0.3"
        }
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
  "recipe[dhcpd]"
)
