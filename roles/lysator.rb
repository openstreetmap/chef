name "lysator"
description "Role applied to all servers at Lysator"

default_attributes(
  :hosted_by => "Lysator",
  :location => "Linköping, Sweden",
  :networking => {
    :nameservers => ["130.236.254.225", "2001:6b0:17:f0a0::e1"],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.se.pool.ntp.org", "1.se.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[se]"
)
