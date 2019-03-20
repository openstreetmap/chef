name "waima"
description "Master role applied to waima"

default_attributes(
  :networking => {
    :netplan => true,
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens3",
        :role => :external,
        :family => :inet,
        :address => "192.168.1.4",
        :prefix => "24",
        :gateway => "192.168.1.1",
        :public_address => "103.197.61.160"
      }
    }
  },
  :squid => {
    :cache_mem => "7500 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "hamilton.render.openstreetmap.org",
    :tile_siblings => [
      "tuatara.openstreetmap.org",
      "longma.openstreetmap.org",
      "storfly-02.openstreetmap.org",
      "jakelong.openstreetmap.org"
    ]
  }
)

run_list(
  "role[catalyst]",
  "role[tilecache]"
)
