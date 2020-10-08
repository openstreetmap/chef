name "umu"
description "Role applied to all servers at Umeå University"

default_attributes(
  :accounts => {
    :users => {
      :maswan => { :status => :administrator }
    }
  },
  :hosted_by => "Academic Computer Club, Umeå University",
  :location => "Umeå, Sweden"
)

override_attributes(
  :networking => {
    :nameservers => ["130.239.18.251", "130.239.18.252", "130.239.1.90"]
  },
  :ntp => {
    :servers => ["0.se.pool.ntp.org", "1.se.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[se]"
)
