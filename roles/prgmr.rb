name "prgmr"
description "Role applied to all servers at prgmr.com"

default_attributes(
  :hosted_by => "prgmr.com",
  :location => "San Francisco, California",
  :timezone => "PST8PDT",
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"]
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.us.pool.ntp.org", "1.us.pool.ntp.org", "2.us.pool.ntp.org"]
  }
)

run_list(
  "role[us]"
)
