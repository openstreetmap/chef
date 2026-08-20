name "lyonix"
description "Role applied to all servers at LyonIX"

default_attributes(
  :hosted_by => "LyonIX",
  :location => "Lyon, France",
  :snmpd => {
    :clients => ["77.95.64.0/21", "2a03:9180::/32", "2001:7f8:47::/48"],
    :community => "lyonix",
    :location => "LYON",
    :contact => "sysadm@rezopole.net"
  }
)

run_list(
  "role[fr]",
  "recipe[snmpd]"
)
