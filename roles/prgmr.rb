name "prgmr"
description "Role applied to all servers at prgmr.com"

default_attributes(
  :hosted_by => "prgmr.com",
  :location => "San Francisco, California",
  :timezone => "PST8PDT"
)

override_attributes(
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "2.us.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
