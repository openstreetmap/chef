name "dulcy"
description "Master role applied to dulcy
"

default_attributes(
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "p18p1",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.109",
        :hwaddress => "0c:c4:7a:66:96:d2"
      },
      :external_ipv6 => {
        :interface => "p18p1",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:ec4:7aff:fe66:96d2"
      },
      :internal_ipv4 => {
        :interface => "p18p2",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.179",
        :hwaddress => "0c:c4:7a:66:96:d3"
      }
    }
  },
  :postgresql => {
    :versions => ["9.4"],
    :settings => {
      :defaults => {
        :work_mem => "300MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :fsync => "on"
      }
    }
  },
  :nominatim => {
    :enabled => false,
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :database => {
      :cluster => "9.4/main",
      :dbname => "nominatim",
      :postgis => "2.1"
    },
    :fpm_pools => {
      :www => {
        :port => "8000",
        :pm => "dynamic",
        :max_children => "60"
      },
      :bulk => {
        :port => "8001",
        :pm => "static",
        :max_children => "10"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[nominatim-standalone]"
)
