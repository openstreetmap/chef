name "planet"
description "Role applied to all planet servers"

default_attributes(
  :accounts => {
    :users => {
      :bretth => { :status => :user },
      :planet => {
        :status => :administrator,
        :members => [:bretth],
      },
    },
  },
  :rsyncd => {
    :modules => {
      :planet => {
        :comment => "Semi public planet.osm archive",
        :path => "/store/planet",
        :read_only => true,
        :write_only => false,
        :list => true,
        :uid => "nobody",
        :gid => "nogroup",
        :transfer_logging => false,
        :exclude => [".*"],
        :max_connections => 10,
        :ignore_errors => true,
        :ignore_nonreadable => true,
        :timeout => 3600,
        :refuse_options => ["checksum"],
      },
    },
  },
  :networking => {
    :firewall => {
      :http_connection_limit => 10,
    },
  },
  :apache => {
    :mpm => "worker",
    :keepalive => true,
    :worker => {
      :server_limit => 20,
      :max_request_workers => 1000,
      :threads_per_child => 50,
      :min_spare_threads => 75,
      :max_spare_threads => 525,
    },
  }
)

run_list(
  "role[web-db]",
  "recipe[planet]",
  "recipe[planet::replication]",
  "recipe[nfs::server]",
  "recipe[rsyncd]"
)
