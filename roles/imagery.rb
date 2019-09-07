name "imagery"
description "Role applied to all imagery servers"

default_attributes(
  :accounts => {
    :users => {
      :htonl => { :status => :user },
      :imagery => {
        :status => :role,
        :members => [:grant, :tomh, :htonl],
      },
    },
  },
  :apt => {
    :sources => %w(nginx ubuntugis-unstable),
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000,
      },
    },
    :kernel_scheduler_tune => {
      :comment => "Tune kernel scheduler preempt",
      :parameters => {
        "kernel.sched_min_granularity_ns" => 10000000,
        "kernel.sched_wakeup_granularity_ns" => 15000000,
      },
    },
    :kernel_tfo_listen_enable => {
      :comment => "Enable TCP Fast Open for listening sockets",
      :parameters => {
        "net.ipv4.tcp_fastopen" => 3,
      },
    },
  },
  :nginx => {
    :cache => {
      :fastcgi => {
        :enable => true,
        :keys_zone => "fastcgi_cache_zone:256M",
        :inactive => "45d",
        :max_size => "51200M",
      },
    },
  }
)

run_list(
  "recipe[imagery::au_agri]",
  "recipe[imagery::gb_ea]",
  "recipe[imagery::gb_hampshire_aerial]",
  "recipe[imagery::gb_os_sv]",
  "recipe[imagery::gb_surrey_aerial]",
  "recipe[imagery::za_ngi_topo]",
  "recipe[imagery::za_coct_aerial]",
  "recipe[imagery::na_sgswa_topo]"
)
