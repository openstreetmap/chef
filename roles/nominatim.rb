name "nominatim"
description "Role applied to all nominatim servers"

default_attributes(
  :accounts => {
    :users => {
      :lonvia => { :status => :administrator },
      :twain => { :status => :administrator },
      :nominatim => {
        :status => :role,
        :members => [ :lonvia, :tomh, :twain ]
      },
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :keepalive => false,
    :event => {
      :server_limit => 32,
      :max_clients => 800,
      :threads_per_child => 50
    }
  },
  :apt => {
    :sources => [ "ubuntugis-stable", "ubuntugis-unstable" ]
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :max_connections => "450",
        :synchronous_commit => "off",
        :checkpoint_segments => "50",
        :checkpoint_timeout => "10min",
        :checkpoint_completion_target => "0.9",
        :autovacuum_max_workers => "1"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => { 
        "kernel.shmmax" => 26 * 1024 * 1024 * 1024,
        "kernel.shmall" => 26 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :nominatim => {
    :repository => "git://git.openstreetmap.org/nominatim.git",
    :database => {
        :cluster => "9.1/main",
        :dbname => "nominatim"
    },
    :fpm_pools => {
        :www => {
            :pm => "dynamic",
            :max_children => "50"
        },
        :bulk => {
            :pm => "static",
            :max_children => "7"
        }
    }
  }
)

run_list(
  "recipe[nominatim]"
)
