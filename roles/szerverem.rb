name "szerverem"
description "Role applied to all servers at szerverem.hu"

default_attributes(
  :networking => {
    :nameservers => [
      "84.2.44.1",
      "84.2.46.1"
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
