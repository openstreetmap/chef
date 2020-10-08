name "jump"
description "Role applied to all servers at Jump Networks"

default_attributes(
  :hosted_by => "Jump Networks",
  :location => "London, England"
)

override_attributes(
  :networking => {
    :nameservers => ["185.73.44.3", "2001:ba8:0:2c02::", "2001:ba8:0:2c03::", "2001:ba8:0:2c04::"]
  },
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
