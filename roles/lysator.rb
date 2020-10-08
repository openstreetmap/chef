name "lysator"
description "Role applied to all servers at Lysator"

default_attributes(
  :accounts => {
    :users => {
      :aoh => { :status => :administrator },
      :lysroot => { :status => :administrator }
    }
  },
  :hosted_by => "Lysator",
  :location => "Linköping, Sweden"
)

override_attributes(
  :networking => {
    :nameservers => ["130.236.254.225", "2001:6b0:17:f0a0::e1", "130.236.254.4"]
  },
  :ntp => {
    :servers => ["0.se.pool.ntp.org", "1.se.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[se]"
)
