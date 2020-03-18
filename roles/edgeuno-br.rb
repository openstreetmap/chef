name "edgeuno-br"
description "Role applied to all servers at Edgeuno BR"

default_attributes(
  :location => "São Paulo, Brasil"
)

override_attributes(
  :ntp => {
    :servers => ["0.br.pool.ntp.org", "1.br.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[br]",
  "role[edgeuno]"
)
