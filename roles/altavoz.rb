name "altavoz"
description "Role applied to all servers at AltaVoz"

default_attributes(
  :hosted_by => "AltaVoz",
  :location => "Viña del Mar, Chile",
  :networking => {
    :nameservers => [
      "200.91.44.10",
      "200.91.41.10",
    ],
    :roles => {
      :external => {
        :zone => "av",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.cl.pool.ntp.org", "1.cl.pool.ntp.org", "america.pool.ntp.org"],
  }
)

run_list(
  "role[cl]"
)
