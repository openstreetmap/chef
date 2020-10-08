name "datahata"
description "Role applied to all servers at DataHata"

default_attributes(
  :accounts => {
    :users => {
      :kom => { :status => :administrator }
    }
  },
  :hosted_by => "DataHata",
  :location => "Minsk, Belarus"
)

override_attributes(
  :ntp => {
    :servers => ["0.by.pool.ntp.org", "1.by.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[by]"
)
