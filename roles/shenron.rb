name "shenron"
description "Master role applied to shenron"

default_attributes(
  :apache => {
    :mpm => "event",
    :event => {
      :min_spare_threads => 50,
      :max_spare_threads => 150
    }
  },
  :hardware => {
    :hwmon => {
      "platform_it87_552" => {
        :ignore => %w[in6]
      }
    },
    :modules => [
      "it87"
    ]
  },
  :prometheus => {
    :metrics => {
      :exim_queue_limit => { :metric => 250 }
    }
  }
)

override_attributes(
  :networking => {
    :dnssec => "false",
    :interfaces => {
      :external => {
        :interface => "eth0",
        :role => :external,
        :inet => {
          :address => "212.110.172.32",
          :prefix => "26",
          :gateway => "212.110.172.1"
        },
        :inet6 => {
          :address => "2001:41c9:1:400::32",
          :prefix => "64",
          :gateway => "fe80::1"
        }
      }
    }
  }
)

run_list(
  "role[bytemark]",
  "role[lists]",
  "role[osqa]"
)
