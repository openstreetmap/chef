name "carnet"
description "Role applied to all servers at CARNet"

default_attributes(
  :accounts => {
    :users => {
      :hbogner => { :status => :administrator }
    }
  },
  :hosted_by => "CARNet"
)

override_attributes(
  :ntp => {
    :servers => ["0.hr.pool.ntp.org", "1.hr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[hr]"
)
