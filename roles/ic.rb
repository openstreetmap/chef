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
          :prefix => "20",
          :gateway => "10.0.48.2"
        }
      },
      :external => {
        :zone => "ic",
        :inet => {
          :prefix => "27",
          :gateway => "130.117.76.30"
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:978:2:2C::172:2"
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
