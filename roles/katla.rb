name "katla"
description "Master role applied to katla"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.173",
        :hwaddress => "00:25:90:94:91:00"
      }
    }
  }
);

run_list(
  "role[ic]"
)
