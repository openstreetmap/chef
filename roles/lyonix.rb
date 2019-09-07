name "lyonix"
description "Role applied to all servers at LyonIX"

default_attributes(
  :hosted_by => "LyonIX",
  :location => "Lyon, France",
  :networking => {
    :nameservers => ["77.95.64.205", "77.95.64.206", "8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "ly",
      },
    },
  },
  :snmpd => {
    :clients => ["77.95.64.0/24", "77.95.70.0/24"],
    :community => "lyonix",
    :location => "LYON",
    :contact => "noc@lyonix.net",
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[fr]",
  "recipe[snmpd]"
)
