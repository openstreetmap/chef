name "szerverem"
description "Role applied to all servers at szerverem.hu"

default_attributes(
  :hosted_by => "szerverem.hu",
  :location => "Budapest, Hungary",
  :networking => {
    :nameservers => [
      "8.8.8.8",
      "8.8.4.4"
    ],
    :roles => {
      :external => {
        :zone => "sz"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.hu.pool.ntp.org", "1.hu.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[hu]"
)
