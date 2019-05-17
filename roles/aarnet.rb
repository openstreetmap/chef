name "aarnet"
description "Role applied to all servers at AARNet"

default_attributes(
  :accounts => {
    :users => {
      :chm => { :status => :administrator },
      :bclifford => { :status => :administrator }
    }
  },
  :hosted_by => "AARNet"
)

override_attributes(
  :ntp => {
    :servers => ["0.au.pool.ntp.org", "1.au.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[au]"
)
