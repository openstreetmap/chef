name "dotsrc"
description "Role applied to all servers at dotsrc.org"

default_attributes(
  :hosted_by => "dotsrc.org",
  :location => "Aalborg, Denmark"
)

override_attributes(
  :ntp => {
    :servers => ["0.dk.pool.ntp.org", "1.dk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[dk]"
)
