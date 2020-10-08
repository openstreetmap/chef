name "teleservice"
description "Role applied to all servers at Teleservice"

default_attributes(
  :hosted_by => "Teleservice Skåne AB",
  :location => "Sjöbo, Sweden"
)

override_attributes(
  :ntp => {
    :servers => ["0.se.pool.ntp.org", "1.se.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[se]"
)
