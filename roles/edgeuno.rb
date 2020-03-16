name "edgeuno"
description "Role applied to all servers at Edgeuno"

default_attributes(
  :hosted_by => "EdgeUno",
  :location => "Bogotá, Colombia",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "1.1.1.1"
    ],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.co.pool.ntp.org", "1.co.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[co]"
)
