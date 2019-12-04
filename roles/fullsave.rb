name "fullsave"
description "Role applied to all servers at FullSave"

default_attributes(
  :hosted_by => "FullSave",
  :location => "Toulouse, France",
  :networking => {
    :firewall => {
      :inet => [
        {
          :action => "ACCEPT",
          :source => "net:185.116.130.12",
          :dest => "fw",
          :proto => "udp",
          :dest_ports => "snmp",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        },
        {
          :action => "ACCEPT",
          :source => "net:100.80.8.0/24",
          :dest => "fw",
          :proto => "udp",
          :dest_ports => "snmp",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        }
      ]
    },
    :nameservers => ["141.0.202.202", "141.0.202.203"],
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
