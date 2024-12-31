name "equinix-dub"
description "Role applied to all servers at Equinix Dublin"

default_attributes(
  :sysctl => {
    :enable_bbr_10g => {
      :comment => "Enable BBR. Equinix Dub has 10G uplink unlikely to buffer overrun",
      :parameters => {
        "net.ipv4.tcp_congestion_control" => "bbr",
        "net.ipv4.tcp_notsent_lowat" => "16384"
      }
    }
  },
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.64.2",
          :routes => {
            "10.0.0.0/8" => { :via => "10.0.64.2" }
          }
        }
      },
      :external => {
        :zone => "dub",
        :inet => {
          :rules => [
            { :to => "10.0.0.0/8", :table => "main", :priority => 50 },
            { :to => "172.16.0.0/12", :table => "main", :priority => 50 },
            { :to => "192.168.0.0/16", :table => "main", :priority => 50 }
          ]
        },
        :inet6 => {
          :rules => [
            { :to => "2600:9000::/28", :table => 150, :priority => 100 }
          ]
        }
      }
    }
  },
  :prometheus => {
    :metrics => {
      :host_location => {
        :help => "Host location",
        :labels => { :site => "dublin" }
      }
    }
  },
  :web => {
    :readonly_database_host => "snap-03.dub.openstreetmap.org"
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.64.2", "74.82.42.42", "2001:470:20::2"],
    :search => ["dub.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.ie.pool.ntp.org", "1.ie.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[ie]"
)
