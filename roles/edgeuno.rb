name "edgeuno"
description "Role applied to all servers at Edgeuno"

default_attributes(
  :accounts => {
    :users => {
      :e1admin => { :status => :administrator }
    }
  },
  :hosted_by => "EdgeUno",
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
    }
  }
)
