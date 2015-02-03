name "owl"
description "Role applied to all OWL servers"

default_attributes(
  :accounts => {
    :users => {
      :yellowbkpk => { :status => :user },
      :ppawel => { :status => :user },
      :owl => {
        :status => :role,
        :members => [:yellowbkpk, :ppawel]
      }
    },
    :groups => {
      :adm => {
        :members => [:yellowbkpk, :ppawel]
      }
    }
  },
  :apache => {
    :mpm => "event"
  },
  :apt => {
    :sources => ["brightbox-ruby-ng", "ubuntugis-stable", "ubuntugis-unstable"]
  },
  :postgresql => {
    :versions => ["9.1"],
    :settings => {
      :defaults => {
        :fsync => "off",
        :checkpoint_segments => "30",
        :checkpoint_completion_target => "0.9",
        :random_page_cost => "2.0",
        :log_min_duration_statement => "3000"
      },
      "9.1" => {
        :port => "5433"
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
  "recipe[owl]"
)
