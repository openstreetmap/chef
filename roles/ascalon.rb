name "ascalon"
description "Master role applied to ascalon"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "184.107.48.228",
        :prefix => "27",
        :gateway => "184.107.48.225"
      }
    }
  },
  :squid => {
    :version => "3",
    :cache_mem => "16000 MB",
    :cache_dir => "rock /store/squid/rock-01 128000 swap-timeout=300 max-swap-rate=50 slot-size=4096 max-size=262144"
  },
  :tilecache => {
    :tile_parent => "montreal.render.openstreetmap.org",
    :tile_siblings => [
      "stormfly-02.openstreetmap.org",
      "jakelong.openstreetmap.org"
    ]
  }
)

run_list(
  "role[netalerts]",
  "role[geodns]",
  "role[tilecache]"
)
