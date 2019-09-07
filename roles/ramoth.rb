name "ramoth"
description "Master role applied to ramoth"

default_attributes(
  :devices => {
    :store_openstreetmap => {
      :comment => "RAID array mounted on /store/postgresql/openstreetmap",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b00599aa401c02b4f53bf5c805",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "975",
      },
    },
    :store_system => {
      :comment => "RAID array mounted on /store/postgresql/system",
      :type => "block",
      :bus => "scsi",
      :serial => "3600605b0039483a017092ff8fa5a6332",
      :attrs => {
        "queue/scheduler" => "deadline",
        "queue/nr_requests" => "975",
      },
    },
  },
  :hardware => {
    :watchdog => "w83627hf_wdt",
  },
  :munin => {
    :plugins => {
      :smart_sg0_33 => {
        :smartctl_exit_status => { :warning => ":8" },
      },
      :smart_sg0_34 => {
        :smartctl_exit_status => { :warning => ":8" },
      },
    },
  },
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.5",
        :bond => {
          :slaves => %w(enp7s0f0 enp7s0f1),
        },
      },
    },
  }
)

run_list(
  "role[equinix]"
)
