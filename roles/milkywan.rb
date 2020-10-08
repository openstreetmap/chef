name "milkywan"
description "Role applied to all servers at MilkyWan"

default_attributes(
  :accounts => {
    :users => {
      :milkywan => { :status => :administrator }
    }
  },
  :hosted_by => "MilkyWan",
  :location => "Paris, France",
  :networking => {
    :firewall => {
      :inet => [
        {
          :action => "ACCEPT",
          :source => "net:212.25.24.64/28",
          :dest => "fw",
          :proto => "udp",
          :dest_ports => "snmp",
          :source_ports => "1024:",
          :rate_limit => "-",
          :connection_limit => "-"
        }
      ]
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
