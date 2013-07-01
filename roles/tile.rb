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
      :shoreline => {
        :url => "http://planet.openstreetmap.org/historical-shapefiles/shoreline_300.tar.bz2",
        :directory => "shoreline_300"
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
      :processed => {
        :url => "http://planet.openstreetmap.org/historical-shapefiles/processed_p.tar.bz2",
        :directory => "processed_p"
      }
    },
    :styles => {
      :default => {
        :repository => "git://github.com/gravitystorm/openstreetmap-carto.git",
        :revision => "v2.2.0",
        :max_zoom => 19
      }
    }
  }
)

run_list(
  "recipe[tile]"
)
