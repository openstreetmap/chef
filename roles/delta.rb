name "delta"
description "Role applied to all servers at Delta Telecom"

default_attributes(
  :hosted_by => "Delta Telecom",
  :location => "Baku, Azerbaijan"
)

override_attributes(
  :ntp => {
    :servers => ["0.az.pool.ntp.org", "1.az.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[az]"
)
