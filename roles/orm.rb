name "orm"
description "Master role applied to orm"

default_attributes(
  :devices => {
    :ssd_samsung => {
      :comment => "Tune scheduler for SSD",
      :type => "block",
      :bus => "ata",
      :serial => "Samsung_SSD_840_PRO_Series_*",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "256",
        "queue/read_ahead_kb" => "2048",
      },
    },
    :arecavoltune => {
      :comment => "Tune scheduler for Areca",
      :type => "block",
      :bus => "scsi",
      :serial => "2001b4d20*",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "512",
        "queue/read_ahead_kb" => "2048",
      },
    },
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.3",
        :bond => {
          :slaves => %w(eth0 eth1),
        },
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.3",
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:3",
      },
    },
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 9 * 1024 * 1024 * 1024,
        "kernel.shmall" => 9 * 1024 * 1024 * 1024 / 4096,
      },
    },
  }
)

override_attributes(
  :networking => {
    :nameservers => ["8.8.8.8", "8.8.4.4"],
  }
)

run_list(
  "role[equinix]",
  "role[tyan-s7010]"
)
