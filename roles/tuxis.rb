name "tuxis"
description "Role applied to all servers at Tuxis"

default_attributes(
  :hosted_by => "Tuxis",
  :location => "Ede, Netherlands"
)

override_attributes(
  :networking => {
    :nameservers => ["2a03:7900:2:0:31:3:104:61", "2a03:7900:2:0:31:3:104:62"]
  },
  :ntp => {
    :servers => ["0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[nl]"
)
