name "yandex"
description "Role applied to all servers at Yandex"

default_attributes(
  :networking => {
    :nameservers => [ "8.8.8.8", "8.8.4.4" ],
    :roles => {
      :external => {
        :zone => "yx"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => [ "0.ru.pool.ntp.org", "1.ru.pool.ntp.org", "europe.pool.ntp.org" ]
  }
)

run_list(
  "role[ru]"
)
