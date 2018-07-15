name "ic"
description "Role applied to all servers at Imperial College"

default_attributes(
  :accounts => {
    :users => {
      :icladmin => { :status => :user }
    }
  },
  :networking => {
    :nameservers => ["8.8.8.8", "146.179.159.177"],
    :roles => {
      :internal => {
        :inet => {
          :prefix => "27",
          :gateway => "146.179.159.177"
        }
      },
      :external => {
        :zone => "ic",
        :inet => {
          :prefix => "27",
          :gateway => "193.63.75.97"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "fe80::5:73ff:fea0:1"
        }
      }
    }
  },
  :web => {
    :backends => %w[rails1 rails2 rails3],
    :fileserver => "ironbelly",
    :readonly_database_host => "karm.ic.openstreetmap.org"
  }
)

override_attributes(
  :networking => {
    :search => ["ic.openstreetmap.org", "openstreetmap.org"]
  },
  :ntp => {
    :servers => ["0.uk.pool.ntp.org", "1.uk.pool.ntp.org", "europe.pool.ntp.org"]
  }
)

run_list(
  "role[gb]"
)
