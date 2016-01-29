name "euserv"
description "Role applied to all servers at EUserv"

default_attributes(
  :hosted_by => "EUserv",
  :location => "Jena, Germany",
  :networking => {
    :nameservers => [
      "85.31.184.60", "85.31.184.61", "85.31.185.60", "85.31.185.61"
    ],
    :roles => {
      :external => {
        :zone => "es"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.de.pool.ntp.org", "1.de.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[de]"
)
