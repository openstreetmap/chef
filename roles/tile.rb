name "tile"
description "Role applied to all tile servers"

default_attributes(
  :accounts => {
    :users => {
      :pnorman => { :status => :administrator },
      :tile => {
        :members => [:jburgess, :tomh, :pnorman]
      }
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :evasive => {
      :enable => false
    },
    :event => {
      :threads_per_child => 20,
      :min_spare_threads => 300,
      :max_connections_per_child => 0,
      :async_request_worker_factor => 4,
      :listen_cores_buckets_ratio => 8
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :max_connections => "250",
        :shared_buffers => "16GB",
        :work_mem => "128MB",
        :maintenance_work_mem => "8GB",
        :max_parallel_workers_per_gather => "0",
        :wal_level => "minimal",
        :wal_buffers => "1024kB",
        :wal_writer_delay => "500ms",
        :checkpoint_timeout => "60min",
        :commit_delay => "10000",
        :max_wal_size => "10GB",
        :max_wal_senders => "0",
        :jit => "off",
        :track_activity_query_size => "16384",
        :autovacuum_vacuum_scale_factor => "0.05",
        :autovacuum_analyze_scale_factor => "0.02"
      }
    }
  },
  :ssl => {
    :ct_report_uri => false
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    },
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "524288"
      }
    },
    :no_tcp_slow_start => {
      :comment => "Disable TCP slow start",
      :parameters => {
        "net.ipv4.tcp_slow_start_after_idle" => "0"
      }
    },
    :tcp_use_bbr => {
      :comment => "Use TCP BBR Congestion Control",
      :parameters => {
        "net.core.default_qdisc" => "fq",
        "net.ipv4.tcp_congestion_control" => "bbr"
      }
    }
  },
  :tile => {
    :database => {
      :style_file => "/srv/tile.openstreetmap.org/styles/default/openstreetmap-carto.style",
      :tag_transform_script => "/srv/tile.openstreetmap.org/styles/default/openstreetmap-carto.lua",
      :external_data_script => "/srv/tile.openstreetmap.org/styles/default/scripts/get-external-data.py -c /srv/tile.openstreetmap.org/styles/default/external-data.yml",
      :external_data_tables => %w[
        icesheet_outlines
        icesheet_polygons
        ne_110m_admin_0_boundary_lines_land
        simplified_water_polygons
        water_polygons
      ]
    },
    :styles => {
      :default => {
        :repository => "https://github.com/gravitystorm/openstreetmap-carto.git",
        :revision => "v5.8.0",
        :fonts_script => "/srv/tile.openstreetmap.org/styles/default/scripts/get-fonts.sh",
        :max_zoom => 19
      }
    }
  }
)

run_list(
  "recipe[tile]"
)
