name "planet"
description "Role applied to all planet servers"

default_attributes(
  :apache => {
    :mpm => "event",
    :keepalive => true,
    :event => {
      :server_limit => 20,
      :max_request_workers => 1000,
      :threads_per_child => 50,
      :min_spare_threads => 75,
      :max_spare_threads => 525,
      :listen_cores_buckets_ratio => 4
    }
  },
  :networking => {
    :firewall => {
      :http_connection_limit => 10
    }
  },
  :prometheus => {
    :files => %w[
      /store/planet/notes/planet-notes-latest.osn.bz2
      /store/planet/pbf/planet-latest.osm.pbf
      /store/planet/planet/changesets-latest.osm.bz2
      /store/planet/planet/discussions-latest.osm.bz2
      /store/planet/planet/planet-latest.osm.bz2
      /store/planet/replication/changesets/state.yaml
      /store/planet/replication/day/state.txt
      /store/planet/replication/hour/state.txt
      /store/planet/replication/minute/state.txt
    ]
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
        :refuse_options => ["checksum"]
      },
      :statistics => {
        :comment => "Statistics",
        :path => "/store/planet/statistics",
        :read_only => false,
        :write_only => true,
        :list => false,
        :uid => "planet",
        :gid => "planet",
        :transfer_logging => false,
        :nodes_allow => "roles:web-statistics"
      }
    }
  }
)

run_list(
  "role[web-db]",
  "recipe[planet]",
  "recipe[planet::replication]",
  "recipe[rsyncd]"
)
