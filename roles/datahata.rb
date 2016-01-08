name "datahata"
description "Role applied to all servers at DataHata"

default_attributes(
  :accounts => {
    :users => {
      :kom => { :status => :administrator }
    }
  },
  :networking => {
    :nameservers => [
      "31.130.200.2"
    ],
    :roles => {
      :external => {
        :zone => "dh"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.by.pool.ntp.org", "1.by.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[by]"
)
