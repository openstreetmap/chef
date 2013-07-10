name "ironbelly"
description "Master role applied to ironbelly"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => ""
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => ""
      },
      :internal_ipv4 => {
        :interface => "eth1",
        :role => :internal,
        :family => :inet,
        :address => ""
      }
    }
  }
);

run_list(
  "role[ic]"
)
