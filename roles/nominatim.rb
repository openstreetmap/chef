name "nominatim"
description "Role applied to all nominatim servers"

default_attributes(
  :accounts => {
    :users => {
      :lonvia => { :status => :administrator },
      :twain => { :status => :administrator }
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 60,
    :keepalive => false,
    :event => {
      :max_clients => 560,
      :threads_per_child => 35
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
        "kernel.shmmax" => 16 * 1024 * 1024 * 1024,
        "kernel.shmall" => 16 * 1024 * 1024 * 1024 / 4096
      }
    }
  }
)

run_list(
  "recipe[nominatim]"
)
