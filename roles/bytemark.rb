name "bytemark"
description "Role applied to all servers at Bytemark"

default_attributes(
  :hosted_by => "Bytemark",
  :location => "York, England",
  :networking => {
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.32.20",
          :routes => {
            "10.0.0.0/8" => { :via => "10.0.32.20" }
          }
        }
      },
      :external => {
        :zone => "bm",
        :inet => {
          :prefix => "28",
          :gateway => "89.16.162.17"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "fe80::1"
        }
      }
    }
  },
  :web => {
    :backends => %w[rails4 rails5],
    :fileserver => "grisu",
    :readonly_database_host => "katla.bm.openstreetmap.org"
  }
)

override_attributes(
  :networking => {
    :nameservers => ["10.0.32.20"],
    :search => ["bm.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
