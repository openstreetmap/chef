name "db"
description "Role applied to all database servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [ :tomh, :grant ]
      }
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
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :listen_addresses => "*",
        :max_connections => "500",
        :max_stack_depth => "7MB",
        :checkpoint_segments => "32",
        :checkpoint_completion_target => "0.8",
        :late_authentication_rules => [
          { :address => "146.179.159.160/27" }
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
