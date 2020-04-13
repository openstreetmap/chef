name "ffrl"
description "Role applied to all servers at Freifunk Rheinland"

default_attributes(
  :hosted_by => "Freifunk Rheinland",
  :location => "Berlin, Germany",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "8.8.4.4"
    ]
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.de.pool.ntp.org", "1.de.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[de]"
)
