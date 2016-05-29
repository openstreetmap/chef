name "imagery"
description "Role applied to all imagery servers"

default_attributes(
  :accounts => {
    :users => {
      :htonl => { :status => :user },
      :imagery => {
        :status => :role,
        :members => [:grant, :tomh, :htonl]
      }
    }
  },
  :apt => {
    :sources => ["nginx"]
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
  :nginx => {
    :cache => {
      :fastcgi => {
        :enable => true
      }
    }
  }
)

run_list(
  "recipe[imagery::au_agri]",
  "recipe[imagery::gb_hampshire_aerial]",
  "recipe[imagery::gb_os_sv]",
  "recipe[imagery::gb_surrey_aerial]"
)
