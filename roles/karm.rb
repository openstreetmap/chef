name "karm"
description "Master role applied to karm"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "enp1s0f0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.168",
        :hwaddress => "0c:c4:7a:a3:aa:ac"
      }
    }
  }
)

run_list(
  "role[ic]"
)
