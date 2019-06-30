name "balerion"
description "Master role applied to balerion"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "bond0",
        :role => :external,
        :family => :inet,
        :address => "138.44.68.134",
        :prefix => "30",
        :gateway => "138.44.68.133",
        :bond => {
          :slaves => %w[ens14f0 ens14f1]
        }
      }
    }
  },
  :squid => {
    :cache_mem => "32000 MB",
    :cache_dir => "coss /store/squid/coss-01 80000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "melbourne.render.openstreetmap.org",
    :tile_siblings => [
      "waima.openstreetmap.org",
      "tuatara.openstreetmap.org",
      "longma.openstreetmap.org"
    ]
  }
)

run_list(
  "role[aarnet]",
  "role[tilecache]"
)
