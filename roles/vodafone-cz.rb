name "vodafone-cz"
description "Role applied to all servers at Vodafone CZ"

default_attributes(
  :hosted_by => "Vodafone",
  :location => "Prague, Czech Republic"
)

override_attributes(
  :networking => {
    :nameservers => ["62.24.64.2", "2a02:8301:0:10::3"]
  },
  :ntp => {
    :servers => ["0.cz.pool.ntp.org", "1.cz.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[cz]"
)
