name "edgeuno-ar"
description "Role applied to all servers at Edgeuno AR"

default_attributes(
  :location => "Buenos Aires, Argentina"
)

override_attributes(
  :ntp => {
    :servers => ["0.ar.pool.ntp.org", "1.ar.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[ar]",
  "role[edgeuno]"
)
