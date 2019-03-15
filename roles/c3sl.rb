name "c3sl"
description "Role applied to all servers at Centro de Computação Científica e Software Livre"

default_attributes(
  :hosted_by => "Centro de Computação Científica e Software Livre, Universidade Federal do Paraná",
  :location => "Curitiba, Brazil",
  :networking => {
    :nameservers => ["200.17.202.3", "200.236.31.1"],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.br.pool.ntp.org", "1.br.pool.ntp.org", "america.pool.ntp.org"]
  }
)

run_list(
  "role[br]"
)
