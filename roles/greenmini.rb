name "greenmini"
description "Role applied to all servers at greenminihost"

default_attributes(
  :accounts => {
    :users => {
      :joris => { :status => :administrator }
    }
  },
  :hosted_by => "greenminihost",
  :location => "Dronten, Netherlands"
)

override_attributes(
  :networking => {
    :nameservers => ["45.148.169.130", "185.200.102.102", "2a0a:aa42:222:2500::2500", "2a0a:aa42:321:2000::53"]
  },
  :ntp => {
    :servers => ["0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[nl]"
)
