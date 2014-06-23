name "ucl-wates"
description "Role applied to all servers at UCL which are in Wates House"

override_attributes(
  :networking => {
    :nameservers => [ "10.0.0.3", "8.8.8.8", "8.8.4.4" ],
    :search => [ "ucl.openstreetmap.org", "openstreetmap.org" ]
  }
)

run_list(
  "role[ucl]"
)
