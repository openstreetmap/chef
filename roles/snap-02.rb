name "snap-02"
description "Master role applied to snap-02"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eno1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.4"
      }
    }
  }
)

run_list(
  "role[ucl]"
)
