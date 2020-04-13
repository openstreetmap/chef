name "zcu"
description "Role applied to all servers at University of West Bohemia"

default_attributes(
  :hosted_by => "University of West Bohemia",
  :location => "Pilsen, Czech Republic",
  :networking => {
    :nameservers => ["147.228.3.3", "147.228.52.11"]
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.cz.pool.ntp.org", "1.cz.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[cz]"
)
