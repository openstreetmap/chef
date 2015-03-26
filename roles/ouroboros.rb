name "ouroboros"
description "Master role applied to ouroboros"

default_attributes(
  :chef => {
    :client => {
      :version => "11.18.0-1"
    }
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.172",
        :hwaddress => "00:23:7d:ea:81:38"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.106",
        :hwaddress => "00:23:7d:ea:81:3a"
      },
      :external_ipv6 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:223:7dff:feea:813a"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[hp-g6]",
  "role[wiki]"
)
