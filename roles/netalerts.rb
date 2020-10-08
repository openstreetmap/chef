name "netalerts"
description "Role applied to all servers at NetAlerts"

default_attributes(
  :hosted_by => "NetAlerts",
  :location => "Montréal, Canada",
  :timezone => "America/Montreal"
)

override_attributes(
  :networking => {
    :nameservers => ["209.172.41.202", "209.172.41.200"]
  },
  :ntp => {
    :servers => ["0.ca.pool.ntp.org", "1.ca.pool.ntp.org", "north-america.pool.ntp.org"]
  }
)

run_list(
  "role[ca]"
)
