name "inxza"
description "Role applied to all servers at INX-ZA"

default_attributes(
  :hosted_by => "INX-ZA",
  :location => "Cape Town, South Africa",
  :networking => {
    :nameservers => [
      "196.10.52.52",
      "196.10.54.54",
      "196.10.55.55",
    ],
    :roles => {
      :external => {
        :zone => "ixz",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.za.pool.ntp.org", "1.za.pool.ntp.org", "africa.pool.ntp.org"],
  }
)

run_list(
  "role[za]"
)
