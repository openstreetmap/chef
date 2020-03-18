name "edgeuno-co"
description "Role applied to all servers at Edgeuno CO"

default_attributes(
  :location => "Bogotá, Colombia"
)

override_attributes(
  :ntp => {
    :servers => ["0.co.pool.ntp.org", "1.co.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[co]",
  "role[edgeuno]"
)
