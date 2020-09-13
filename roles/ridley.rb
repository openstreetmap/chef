name "ridley"
description "Master role applied to ridley"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :min_spare_threads => 50,
      :max_spare_threads => 150,
      :max_connections_per_child => 10000,
      :async_request_worker_factor => 4,
      :listen_cores_buckets_ratio => 4
    }
  },
  :bind => {
    :clients => "ucl"
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
  "role[switch2osm]",
  "role[blog]",
  "role[otrs]",
  "role[donate]",
  "recipe[hot]",
  "recipe[dmca]",
  "recipe[dhcpd]"
)
