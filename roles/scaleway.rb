name "scaleway"
description "Role applied to all servers at Scaleway"

default_attributes(
  :hosted_by => "Scaleway",
  :location => "Paris, France"
)

override_attributes(
  :networking => {
    :nameservers => ["62.210.16.6", "62.210.16.7"]
  },
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
