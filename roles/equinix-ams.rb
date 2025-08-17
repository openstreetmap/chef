name "equinix-ams"
description "Role applied to all servers at Equinix Amsterdam"

default_attributes(
  :sysctl => {
    :enable_bbr_10g => {
      :comment => "Enable BBR. Equinix AMS has 3Gbps uplinks",
      :parameters => {
        "net.core.default_qdisc" => "fq",
        "net.ipv4.tcp_congestion_control" => "bbr"
      }
    }
  },
  :networking => {
    :interfaces => {
      :internal => {
        :interface => "bond0",
        :role => :internal,
        :metric => 200,
        :inet => {
          :prefix => "20",
          :gateway => "10.0.48.14",
          :routes => {
            "10.0.0.0/8" => { :via => "10.0.48.14" }
          }
        },
        :bond => {
          :mode => "802.3ad",
          :lacprate => "fast",
          :xmithashpolicy => "layer3+4"
        }
      }
    }
  },
  :prometheus => {
    :metrics => {
      :host_location => {
        :help => "Host location",
        :labels => { :site => "amsterdam" }
      }
    }
  },
  :web => {
    :readonly_database_host => "snap-01.ams.openstreetmap.org",
    :primary_cluster => true
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.48.14", "8.8.8.8", "8.8.4.4"],
    :search => ["ams.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[nl]"
)
