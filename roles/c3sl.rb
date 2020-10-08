name "c3sl"
description "Role applied to all servers at Centro de Computação Científica e Software Livre"

default_attributes(
  :accounts => {
    :users => {
      :c3sl => { :status => :administrator }
    }
  },
  :hosted_by => "Centro de Computação Científica e Software Livre, Universidade Federal do Paraná",
  :location => "Curitiba, Brazil",
  :networking => {
    :wireguard => { :keepalive => 180 }
  },
  :timezone => "America/Sao_Paulo"
)

override_attributes(
  :networking => {
    :nameservers => ["200.17.202.3", "200.236.31.1"]
  },
  :ntp => {
    :servers => ["0.br.pool.ntp.org", "1.br.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[br]"
)
