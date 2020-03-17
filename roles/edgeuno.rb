name "edgeuno"
description "Role applied to all servers at Edgeuno"

default_attributes(
  :hosted_by => "EdgeUno",
  :location => "Bogotá, Colombia",
  :networking => {
    :firewall => {
      :inet => [
        {
          :action => "ACCEPT",
          :source => "net:200.25.3.8/31",
          :dest => "fw",
          :proto => "udp",
          :dest_ports => "snmp",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        },
        {
          :action => "ACCEPT",
          :source => "net:200.25.3.8/31",
          :dest => "fw",
          :proto => "tcp",
          :dest_ports => "snmp",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        }
      ]
    },
    :nameservers => [
      "8.8.8.8",
      "1.1.1.1"
    ],
    :roles => {
      :external => {
        :zone => "osm"
      }
    }
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.co.pool.ntp.org", "1.co.pool.ntp.org", "south-america.pool.ntp.org"]
  }
)

run_list(
  "role[co]"
)
