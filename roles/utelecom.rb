name "utelecom"
description "Role applied to all servers at Ukrainian Telecommunication Group"

default_attributes(
  :hosted_by => "Ukrainian Telecommunication Group",
  :location => "Kiev, Ukraine"
)

override_attributes(
  :ntp => {
    :servers => ["0.ua.pool.ntp.org", "1.ua.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[ua]"
)
