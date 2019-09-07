name "iway"
description "Role applied to all servers at iWay"

default_attributes(
  :accounts => {
    :users => {
      :cramer => { :status => :administrator },
    },
  },
  :hosted_by => "iWay",
  :location => "Zurich, Switzerland",
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
          :connection_limit => "-",
        },
      ],
    },
    :nameservers => ["2001:8e0:ffff:ac1::1", "8.8.8.8", "8.8.4.4"],
    :roles => {
      :external => {
        :zone => "osm",
      },
    },
  }
)

override_attributes(
  :ntp => {
    :servers => ["0.ch.pool.ntp.org", "1.ch.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[ch]"
)
