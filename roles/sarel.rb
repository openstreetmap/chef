name "sarel"
description "Master role applied to sarel"

default_attributes(
  :git => {
    :allowed_nodes => "fqdn:*",
    :user => "chefrepo",
    :group => "chefrepo",
    :backup => "chef-git"
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.12"
      },
      :external_ipv4 => {
        :interface => "eth0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.20"
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[hp-g5]",
  "role[yournavigation]",
  "role[chef-server]",
  "role[chef-repository]",
  "role[letsencrypt]",
  "recipe[git::server]",
  "recipe[serverinfo]"
)
