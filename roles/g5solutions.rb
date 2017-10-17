name "g5solutions"
description "Role applied to all servers at G5 Solutions"

default_attributes(
  :hosted_by => "G5 Solutions",
  :location => "Indonesia",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "8.8.4.4"
    ],
    :roles => {
      :external => {
        :zone => "g5s"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.id.pool.ntp.org", "1.id.pool.ntp.org", "asia.pool.ntp.org"]
  }
)

run_list(
  "role[id]"
)
