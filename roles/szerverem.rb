name "szerverem"
description "Role applied to all servers at szerverem.hu"

default_attributes(
  :hosted_by => "szerverem.hu",
  :location => "Budapest, Hungary"
)

override_attributes(
  :ntp => {
    :servers => ["0.hu.pool.ntp.org", "1.hu.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[hu]"
)
