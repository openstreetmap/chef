name "cherufe"
description "Master role applied to cherufe"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "ens18",
        :role => :external,
        :family => :inet,
        :address => "200.91.44.37",
        :prefix => "23",
        :gateway => "200.91.44.1"
      }
    }
  },
  :openssh => {
    :port => 45222
  },
  :squid => {
    :cache_mem => "6000 MB",
    :cache_dir => "coss /store/squid/coss-01 128000 block-size=8192 max-size=262144 membufs=80"
  },
  :tilecache => {
    :tile_parent => "vinadelmar.render.openstreetmap.org",
    :tile_siblings => [
      "boitata.openstreetmap.org",
      "ascalon.openstreetmap.org",
      "stormfly-02.openstreetmap.org",
      "jakelong.openstreetmap.org"
    ]
  }
)

run_list(
  "role[altavoz]",
  "role[tilecache]"
)
