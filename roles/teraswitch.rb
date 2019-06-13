name "teraswitch"
description "Role applied to all servers at TeraSwitch Networks"

default_attributes(
  :hosted_by => "TeraSwitch Networks",
  :location => "Pittsburgh, Pennsylvania",
  :networking => {
    :nameservers => [
      "1.1.1.1",
      "8.8.8.8"
    ],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "america.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
