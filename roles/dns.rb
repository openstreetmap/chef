name "dns"
description "Role applied to DNS management servers"

default_attributes(
  :dns => {
    :repository => "/var/lib/git/dns.git"
  }
)

run_list(
  "recipe[dns]"
)
