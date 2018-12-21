name "tile"
description "Role applied to all tile servers"

default_attributes(
  :accounts => {
    :users => {
      :tile => {
        :status => :role,
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
      :async_request_worker_factor => 4
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
        :wal_buffers => "1024kB",
        :wal_writer_delay => "500ms",
        :commit_delay => "10000",
        :checkpoint_segments => "60",
        :max_wal_size => "2880MB",
        :random_page_cost => "1.1",
        :track_activity_query_size => "16384",
        :autovacuum_vacuum_scale_factor => "0.05",
        :autovacuum_analyze_scale_factor => "0.02"
      }
    }
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    },
    :kernel_scheduler_tune => {
      :comment => "Tune kernel scheduler preempt",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    }
  },
  :tile => {
    :data => {
      :world_boundaries => {
        :url => "https://planet.openstreetmap.org/historical-shapefiles/world_boundaries-spherical.tgz"
      },
      :simplified_land_polygons => {
        :url => "http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip",
        :refresh => true
      },
      :admin_boundaries => {
        :url => "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip",
        :directory => "ne_110m_admin_0_boundary_lines_land"
      },
      :land_polygons => {
        :url => "http://data.openstreetmapdata.com/land-polygons-split-3857.zip",
        :refresh => true
      },
      :antarctica_icesheet_polygons => {
        :url => "http://data.openstreetmapdata.com/antarctica-icesheet-polygons-3857.zip",
        :refresh => true
      },
      :antarctica_icesheet_outlines => {
        :url => "http://data.openstreetmapdata.com/antarctica-icesheet-outlines-3857.zip",
        :refresh => true
      }
    },
    :styles => {
      :default => {
        :repository => "git://github.com/gravitystorm/openstreetmap-carto.git",
        :revision => "v4.18.0",
        :max_zoom => 19
      }
    }
  }
)

run_list(
  "recipe[tile]"
)
