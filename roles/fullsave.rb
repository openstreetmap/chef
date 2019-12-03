name "fullsave"
description "Role applied to all servers at FullSave"

default_attributes(
  :hosted_by => "FullSave",
  :location => "Toulouse, France",
  :networking => {
    :nameservers => ["141.0.202.202", "141.0.202.203"],
    :roles => {
      :external => {
        :zone => "osm"
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
