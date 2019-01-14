name "proxgroup"
description "Role applied to all servers at ProxGroup"

default_attributes(
  :hosted_by => "ProxGroup",
  :location => "Paris, France",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
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
