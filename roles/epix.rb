name "epix"
description "Role applied to all servers at EPIX"

default_attributes(
  :hosted_by => "EPIX",
  :location => "Katowice, Poland"
)

override_attributes(
  :ntp => {
    :servers => ["0.pl.pool.ntp.org", "1.pl.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[pl]"
)
