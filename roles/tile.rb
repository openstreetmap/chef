name "tile"
description "Role applied to all tile servers"

default_attributes(
  :accounts => {
    :users => {
      :tile => {
        :members => [:jburgess, :tomh]
      }
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :event => {
      :server_limit => 60,
      :max_request_workers => 1200,
      :threads_per_child => 20,
      :min_spare_threads => 300,
      :max_spare_threads => 1200,
      :max_connections_per_child => 0,
      :async_request_worker_factor => 4,
      :listen_cores_buckets_ratio => 6
    }
  },
  :munin => {
    :plugins => {
      :renderd_processed => {
        :graph_order => "reqPrio req reqLow dirty reqBulk dropped",
        :reqPrio => { :draw => "AREA" },
        :req => { :draw => "STACK" }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :max_connections => "250",
        :temp_buffers => "32MB",
        :work_mem => "128MB",
        :max_parallel_workers_per_gather => "0",
        :wal_buffers => "1024kB",
        :wal_writer_delay => "500ms",
        :commit_delay => "10000",
        :checkpoint_segments => "60",
        :max_wal_size => "2880MB",
        :random_page_cost => "1.1",
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
    },
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
        :revision => "v5.4.0",
        :max_zoom => 19
      }
    }
  }
)

run_list(
  "recipe[tile]"
)
