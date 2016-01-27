name "ucl"
description "Role applied to all servers at UCL"

default_attributes(
  :bind => {
    :forwarders => ["144.82.100.1", "144.82.100.41"]
  },
  :location => "London, England"
)

override_attributes(
  :ntp => {
    :servers => ["ntp1.ucl.ac.uk", "ntp2.ucl.ac.uk"]
  }
)

run_list(
  "role[gb]"
)
