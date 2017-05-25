name "grnet"
description "Role applied to all servers at GRNET"

default_attributes(
  :hosted_by => "GRNET",
  :location => "Athens, Greece",
  :networking => {
    :nameservers => [
      "83.212.2.77"
    ],
    :roles => {
      :external => {
        :zone => "grn"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.gr.pool.ntp.org", "1.gr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gr]"
)
