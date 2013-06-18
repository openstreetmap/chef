name "tile-old"
description "Role applied to all tile servers"

default_attributes(
  :apt => {
    :sources => [ "pitti-postgresql" ]
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    }
  }
)
