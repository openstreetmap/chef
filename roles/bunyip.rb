name "bunyip"
description "Master role applied to bunyip"

default_attributes(
  :devices => {
    :os1 => {
      :comment => "First os disk",
      :type => "block",
      :bus => "cciss",
      :serial => "3600508b1001844585154453137470008",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512"
      }
    },
    :tile1 => {
      :comment => "First tile disk",
      :type => "block",
      :bus => "cciss",
      :serial => "3600508b1001844585154453137470009",
      :owner => "proxy",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512"
      }
    },
    :tile2 => {
      :comment => "Second tile disk",
      :type => "block",
      :bus => "cciss",
      :serial => "3600508b100184458515445313747000a",
      :owner => "proxy",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512"
      }
    },
    :tile3 => {
      :comment => "Third tile disk",
      :type => "block",
      :bus => "cciss",
      :serial => "3600508b100184458515445313747000b",
      :owner => "proxy",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512"
      }
    },
    :tile4 => {
      :comment => "Fourth tile disk",
      :type => "block",
      :bus => "cciss",
      :serial => "3600508b100184458515445313747000c",
      :owner => "proxy",
      :attrs => {
        "queue/scheduler" => "noop",
        "queue/nr_requests" => "512"
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "203.26.72.12",
        :prefix => "28",
        :gateway => "203.26.72.14"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2402:6400:1:6:217:8ff:fe56:40c3",
        :prefix => "64"
      }
    }
  },
  :squid => {
    :cache_mem => "5000 MB",
    :cache_dir => "coss /dev/cciss/c0d1 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "brisbane.render.openstreetmap.org",
    :tile_siblings => [
      "jakelong.openstreetmap.org",
      "nadder-01.openstreetmap.org",
      "nadder-02.openstreetmap.org"
    ]
  }
)

run_list(
  "role[racs]",
  "role[tilecache]"
)
