name "grifon"
description "Role applied to all servers at Grifon"

default_attributes(
  :hosted_by => "Grifon",
  :location => "Paris, France",
  :munin => {
    :allow => ["2a00:5884::8"]
  },
  :networking => {
    :nameservers => ["2a00:5884::7"],
    :roles => {
      :external => {
        :zone => "grf"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.fr.pool.ntp.org", "1.fr.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[fr]"
)
