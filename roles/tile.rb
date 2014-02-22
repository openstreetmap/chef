name "tile"
description "Role applied to all tile servers"

default_attributes(
  :accounts => {
    :users => {
      :tile => {
        :status => :role,
        :members => [ :jburgess, :tomh ]
      },
    },
  },
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :event => {
      :server_limit => 60,
      :max_clients => 1200,
      :threads_per_child => 20,
      :min_spare_threads => 30,
      :max_spare_threads => 180,
      :max_requests_per_child => 100000
    }
  },
  :apt => {
    :sources => [ "ubuntugis-stable" ]
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :temp_buffers => "32MB",
        :work_mem => "128MB",
        :wal_buffers => "1024kB",
        :wal_writer_delay => "500ms",
        :commit_delay => "10000",
        :checkpoint_segments => "60"
      }
    }
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    }
  },
  :tile => {
    :database => {
      :cluster => "9.1/main"
    },
    :data => {
      :world_boundaries => {
        :url => "http://planet.openstreetmap.org/historical-shapefiles/world_boundaries-spherical.tgz"
      },
      :simplified_land_polygons => {
        :url => "http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip",
        :refresh => true
      },
      :admin_boundaries => {
        :url => "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_boundary_lines_land.zip",
        :directory => "ne_110m_admin_0_boundary_lines_land"
      },
      :populated_places => {
        :url => "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip",
        :directory => "ne_10m_populated_places",
        :original => "ne_10m_populated_places.shp",
        :processed => "ne_10m_populated_places_fixed.shp"
      },
      :land_polygons => {
        :url => "http://data.openstreetmapdata.com/land-polygons-split-3857.zip",
        :refresh => true
      }
    },
    :styles => {
      :default => {
        :repository => "git://github.com/gravitystorm/openstreetmap-carto.git",
        :revision => "v2.9.1",
        :max_zoom => 19
      }
    }
  }
)

run_list(
  "recipe[tile]"
)
