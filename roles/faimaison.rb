name "faimaison"
description "Role applied to all servers at FAImaison"

default_attributes(
  :hosted_by => "FAImaison",
  :location => "France",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "8.8.4.4",
      "1.1.1.1"
    ]
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
