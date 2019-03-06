name "catalyst"
description "Role applied to all servers at Catalyst"

default_attributes(
  :hosted_by => "Catalyst",
  :location => "Hamilton, New Zealand",
  :networking => {
    :nameservers => ["202.78.244.85", "202.78.244.86", "202.78.244.87"],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.nz.pool.ntp.org", "1.nz.pool.ntp.org", "asia.pool.ntp.org"]
  }
)

run_list(
  "role[nz]"
)
