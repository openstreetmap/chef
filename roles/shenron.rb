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
    :mcelog => {
      :enabled => false
    },
    :modules => [
      "it87"
    ]
  }
)

override_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "212.110.172.32",
        :prefix => "26",
        :gateway => "212.110.172.1"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:41c9:1:400::32",
        :prefix => "64",
        :gateway => "fe80::1"
      }
    },
    :nameservers => ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"],
    :private_address => "10.0.16.100"
  }
)

run_list(
  "role[bytemark]",
  "role[mail]",
  "role[lists]",
  "role[subversion]",
  "role[trac]",
  "role[osqa]",
  "role[irc]",
  "recipe[blogs]"
)
