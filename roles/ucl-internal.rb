name "ucl-internal"
description "Role applied to all servers at UCL which are on the internal LAN"

override_attributes(
  :networking => {
    :nameservers => [ "10.0.0.3", "8.8.8.8", "8.8.4.4" ],
    :search => [ "ucl.openstreetmap.org", "openstreetmap.org" ]
  }
)

run_list(
  "role[ucl]"
)
