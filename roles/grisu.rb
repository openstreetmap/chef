name "grisu"
description "Master role applied to grisu"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "em1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.108",
        :hwaddress => "d8:d3:85:5d:87:a0"
      },
      :external_ipv6 => {
        :interface => "em1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:dad3:85ff:fe5d:87a0"
      },
      :internal_ipv4 => {
        :interface => "em2",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.168",
        :hwaddress => "d8:d3:85:5d:87:a1"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[hp-dl180-g6]",
  "role[imagery]"
)
