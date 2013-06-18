name "ucl-external"
description "Role applied to all servers at UCL which are only on the external LAN"

default_attributes(
  :networking => {
    :nameservers => [ "128.40.168.102", "8.8.8.8", "8.8.4.4" ]
  }
)

run_list(
  "role[ucl]"
)
