name "appliwave"
description "Role applied to all servers at Appliwave"

default_attributes(
  :hosted_by => "Appliwave",
  :location => "Croissy-Beaubourg, France"
)

override_attributes(
  :networking => {
    :nameservers => ["185.73.206.93", "185.73.206.94"]
  },
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
