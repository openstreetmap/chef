name "vectortile"
description "Role applied to all vector tile servers"

default_attributes(
  :accounts => {
    :users => {
      :pnorman => { :status => :administrator },
      :tile => {
        :members => [:tomh, :pnorman]
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :shared_buffers => "16GB",
        :work_mem => "128MB",
        :maintenance_work_mem => "8GB",
        :max_parallel_workers_per_gather => "0",
        :wal_level => "minimal",
        :wal_buffers => "1024kB",
        :wal_writer_delay => "500ms",
        :checkpoint_timeout => "60min",
        :commit_delay => "10000",
        :max_wal_size => "10GB",
        :max_wal_senders => "0",
        :jit => "off",
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
    :network_conntrack_time_wait => {
      :comment => "Only track completed connections for 30 seconds",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" => "30"
      }
    },
    :network_conntrack_max => {
      :comment => "Increase max number of connections tracked",
      :parameters => {
        "net.netfilter.nf_conntrack_max" => "524288"
      }
    },
    :no_tcp_slow_start => {
      :comment => "Disable TCP slow start",
      :parameters => {
        "net.ipv4.tcp_slow_start_after_idle" => "0"
      }
    },
    :tcp_use_bbr => {
      :comment => "Use TCP BBR Congestion Control",
      :parameters => {
        "net.core.default_qdisc" => "fq",
        "net.ipv4.tcp_congestion_control" => "bbr"
      }
    }
  }
)

run_list(
  "recipe[vectortile]"
)
