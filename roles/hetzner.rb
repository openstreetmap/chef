name "hetzner"
description "Role applied to all servers at Hetzner"

default_attributes(
  :hosted_by => "Hetzner"
)

override_attributes(
  :networking => {
    :nameservers => [
      "213.133.98.98",
      "213.133.99.99",
      "213.133.100.100",
      "2a01:4f8:0:a111::add:9898",
      "2a01:4f8:0:a102::add:9999",
      "2a01:4f8:0:a0a1::add:1010"
    ]
  },
  :ntp => {
    :servers => ["0.de.pool.ntp.org", "1.de.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[de]"
)
