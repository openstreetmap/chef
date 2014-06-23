name "faffy"
description "Master role applied to faffy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.7"
      },
      :external_ipv4 => {
        :interface => "eth1",
        :role => :external,
        :family => :inet,
        :address => "128.40.168.108"
      }
    }
  },
  :rsyncd => {
    :modules => {
      :agri_imagery => {
        :comment => "AGRI Imagery Archive",
        :path => "/mnt/md0/agri",
        :read_only => true,
        :write_only => false,
        :list => true,
        :uid => "nobody",
        :gid => "nogroup",
        :transfer_logging => false,
        :exclude => [ ".*" ],
        :max_connections => 10,
        :ignore_errors => true,
        :ignore_nonreadable => true,
        :timeout => 3600,
        :refuse_options => [ "checksum" ]
      },
      :agri_extra => {
        :comment => "AGRI Extras Archive",
        :path => "/var/www/agri.openstreetmap.org/download",
        :read_only => true,
        :write_only => false,
        :list => true,
        :uid => "nobody",
        :gid => "nogroup",
        :transfer_logging => false,
        :exclude => [ ".*" ],
        :max_connections => 10,
        :ignore_errors => true,
        :ignore_nonreadable => true,
        :timeout => 3600,
        :refuse_options => [ "checksum" ]
      }
    }
  }
)

run_list(
  "role[ucl-wates]",
  "recipe[rsyncd]"
)
