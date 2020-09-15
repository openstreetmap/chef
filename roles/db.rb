name "db"
description "Role applied to all database servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [:tomh, :grant]
      }
    }
  },
  :apt => {
    :unattended_upgrades => {
      :enable => false
    }
  },
  :munin => {
    :plugins => {
      :postgres_connections_openstreetmap => {
        :waiting => {
          :warning => 10,
          :critical => 20
        }
      },
      :postgres_locks_openstreetmap => {
        :accesssharelock => {
          :warning => 900,
          :critical => 1000
        },
        :rowexclusivelock => {
          :warning => 250,
          :critical => 300
        }
      }
    }
  },
  :nfs => {
    "/store/rails" => { :host => "ironbelly", :path => "/store/rails" }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :listen_addresses => "*",
        :max_connections => "1000",
        :max_stack_depth => "7MB",
        :checkpoint_segments => "32",
        :max_wal_size => "1536MB",
        :checkpoint_completion_target => "0.8",
        :cpu_tuple_cost => "0.1",
        :log_min_duration_statement => "1000",
        :late_authentication_rules => [
          { :address => "10.0.32.0/20" },
          { :address => "10.0.48.0/20" }
        ]
      }
    }
  },
  :sysctl => {
    :swappiness => {
      :comment => "Only swap in an emergency",
      :parameters => {
        "vm.swappiness" => 0
      }
    }
  }
)

run_list(
  "recipe[nfs]"
)
