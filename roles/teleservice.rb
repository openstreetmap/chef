name "teleservice"
description "Role applied to all servers at Teleservice"

default_attributes(
  :hosted_by => "Teleservice Skåne AB",
  :location => "Sjöbo, Sweden",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "ts",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.se.pool.ntp.org", "1.se.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[se]"
)
