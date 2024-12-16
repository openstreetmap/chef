name "equinix-ams"
description "Role applied to all servers at Equinix Amsterdam"

default_attributes(
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.48.14",
          :routes => {
            "10.0.0.0/8" => { :via => "10.0.48.14" }
          }
        }
      },
      :external => {
        :zone => "ams",
        :inet => {
          :prefix => "27",
          :gateway => "82.199.86.97"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:4d78:500:5e3::1",
          :routes => {
            "2600:9000::/28" => { :type => "unreachable" }
          }
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
    :nameservers => ["10.0.48.14", "74.82.42.42", "2001:470:20::2"],
    :search => ["ams.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[nl]"
)
