name "ovh"
description "Role applied to all servers at OVH"

default_attributes(
  :hosted_by => "OVH",
  :location => "Roubaix, France"
)

override_attributes(
  :networking => {
    :nameservers => ["213.186.33.99"]
  },
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
