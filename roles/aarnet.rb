name "aarnet"
description "Role applied to all servers at AARNet"

default_attributes(
  :accounts => {
    :users => {
      :chm => { :status => :administrator },
      :bclifford => { :status => :administrator }
    }
  },
  :hosted_by => "AARNet",
  :location => "Carlton, Victoria, Australia",
  :timezone => "Australia/Melbourne"
)

override_attributes(
  :networking => {
    :nameservers => ["202.158.207.1", "202.158.207.2"]
  },
  :ntp => {
    :servers => ["0.au.pool.ntp.org", "1.au.pool.ntp.org", "oceania.pool.ntp.org"]
  }
)

run_list(
  "role[au]"
)
