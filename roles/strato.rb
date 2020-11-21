name "strato"
description "Role applied to all servers at Strato"

default_attributes(
  :hosted_by => "Strato",
  :location => "Germany"
)

override_attributes(
  :networking => {
    :nameservers => ["85.214.7.22", "81.169.163.106"]
  },
  :ntp => {
    :servers => ["0.de.pool.ntp.org", "1.de.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[de]"
)
