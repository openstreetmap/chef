name "grnet"
description "Role applied to all servers at GRNET"

default_attributes(
  :accounts => {
    :users => {
      :grnet => { :status => :administrator }
    }
  },
  :hosted_by => "GRNET",
  :location => "Athens, Greece",
  :networking => {
    :nameservers => [
      "2001:648:2ffc:2202::1",
      "83.212.2.77",
      "194.177.210.211"
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
