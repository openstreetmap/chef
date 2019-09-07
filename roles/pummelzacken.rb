name "pummelzacken"
description "Master role applied to pummelzacken"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "em1.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.20",
      },
      :external_ipv4 => {
        :interface => "em1.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.18",
      },
    },
  },
  :postgresql => {
    :versions => ["10"],
    :settings => {
      :defaults => {
        :listen_addresses => "10.0.0.20",
        :work_mem => "160MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :fsync => "on",
      },
    },
  },
  :nominatim => {
    :state => "standalone",
    :dbadmins => %w(lonvia tomh),
    :dbcluster => "10/main",
    :postgis => "2.4",
    :enable_backup => true,
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :tablespaces => {
      "dosm" => "/ssd/tablespaces/dosm",
      "iosm" => "/ssd/tablespaces/iosm",
      "dplace" => "/ssd/tablespaces/dplace",
      "iplace" => "/ssd/tablespaces/iplace",
      "daddress" => "/ssd/tablespaces/daddress",
      "iaddress" => "/ssd/tablespaces/iaddress",
      "dsearch" => "/ssd/tablespaces/dsearch",
      "isearch" => "/ssd/tablespaces/isearch",
      "daux" => "/data/tablespaces/daux",
      "iaux" => "/data/tablespaces/iaux",
    },
    :fpm_pools => {
      :www => {
        :max_children => "40",
      },
    },
  }
)

run_list(
  "role[ucl]",
  "role[nominatim]"
)
