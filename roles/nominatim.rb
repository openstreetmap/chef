name "nominatim"
description "Role applied to all nominatim servers."

default_attributes(
  :accounts => {
    :users => {
      :lonvia => { :status => :administrator },
      :nominatim => {
        :status => :role,
        :members => [:lonvia, :tomh]
      }
    }
  },
  :networking => {
    :firewall => {
      :http_rate_limit => "s:2/sec:15"
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :max_connections => "450",
        :synchronous_commit => "off",
        :checkpoint_segments => "32",
        :checkpoint_timeout => "10min",
        :checkpoint_completion_target => "0.9",
        :jit => "off",
        :shared_buffers => "2GB",
        :autovacuum_max_workers => "1",
        :max_parallel_workers_per_gather => "0",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB"
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
    },
    :kernel_scheduler_tune => {
      :comment => "Tune kernel scheduler preempt",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000
      }
    },
    :swappiness => {
      :comment => "Reduce swap usage",
      :parameters => {
        "vm.swappiness" => 10
      }
    },
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "196608"
      }
    }
  },
  :nominatim => {
    :dbadmins => %w[lonvia tomh],
    :tablespaces => {
      "dosm" => "/ssd/tablespaces/dosm",
      "iosm" => "/ssd/tablespaces/iosm",
      "dplace" => "/ssd/tablespaces/dplace",
      "iplace" => "/ssd/tablespaces/iplace",
      "daddress" => "/ssd/tablespaces/daddress",
      "iaddress" => "/ssd/tablespaces/iaddress",
      "dsearch" => "/ssd/tablespaces/dsearch",
      "isearch" => "/ssd/tablespaces/isearch",
      "daux" => "/ssd/tablespaces/daux",
      "iaux" => "/ssd/tablespaces/iaux"
    }
  }
)

run_list(
  "recipe[nominatim::default]"
)
