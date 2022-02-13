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
          :prefix => "27",
          :gateway => "184.104.226.97"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:470:1:b3b::1",
          :routes => {
            "2001:978:2:2c::/64" => { :type => "unreachable" }
          }
        }
      }
    }
  },
  :web => {
    :fileserver => "fafnir",
    :readonly_database_host => "snap-03.dub.openstreetmap.org"
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.64.2", "1.1.1.1", "1.0.0.1"],
    :search => ["dub.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.ie.pool.ntp.org", "1.ie.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[ie]"
)
