name "equinix"
description "Role applied to all servers at Equinix"

default_attributes(
  :networking => {
    :nameservers => ["66.28.0.45", "66.28.0.61", "2001:978:1:1::d", "2001:978:1:2::d"],
    :roles => {
      :internal => {
        :inet => {
          :prefix => "20",
          :gateway => "10.0.48.10",
        },
      },
      :external => {
        :zone => "ams",
        :inet => {
          :prefix => "27",
          :gateway => "130.117.76.1",
        },
        :inet6 => {
          :prefix => "64",
          :gateway => "2001:978:2:2C::172:1",
        },
      },
    },
  },
  :web => {
    :backends => %w(rails1 rails2 rails3),
    :fileserver => "ironbelly",
    :readonly_database_host => "karm.ams.openstreetmap.org",
    :primary_cluster => true,
  }
)

override_attributes(
  :networking => {
    :search => ["ams.openstreetmap.org", "openstreetmap.org"],
  },
  :ntp => {
    :servers => ["0.nl.pool.ntp.org", "1.nl.pool.ntp.org", "europe.pool.ntp.org"],
  }
)

run_list(
  "role[nl]"
)
