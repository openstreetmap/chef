name "datahata"
description "Role applied to all servers at DataHata"

default_attributes(
  :accounts => {
    :users => {
      :kom => { :status => :administrator }
    }
  },
  :hosted_by => "DataHata",
  :location => "Minsk, Belarus",
  :networking => {
    :nameservers => [
      "31.130.200.2",
      "8.8.8.8",
      "8.8.4.4"
    ]
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
