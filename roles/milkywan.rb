name "milkywan"
description "Role applied to all servers at MilkyWan"

default_attributes(
  :accounts => {
    :users => {
      :milkywan => { :status => :administrator }
    }
  },
  :hosted_by => "MilkyWan",
  :location => "France",
  :networking => {
    :nameservers => ["130.117.11.11", "2a0b:cbc0:42::42"],
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
