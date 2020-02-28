name "sarel"
description "Master role applied to sarel"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :min_spare_threads => 50,
      :max_spare_threads => 150,
      :listen_cores_buckets_ratio => 4
    }
  },
  :git => {
    :private_user => "chefrepo",
    :private_group => "chefrepo"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp3s0f0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.12"
      },
      :external_ipv4 => {
        :interface => "enp3s0f0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.20"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[chef-server]",
  "role[chef-repository]",
  "role[letsencrypt]",
  "role[git]",
  "role[dns]",
  "recipe[serverinfo]"
)
