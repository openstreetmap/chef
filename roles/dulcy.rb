name "dulcy"
description "Master role applied to dulcy"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.48.9",
        :bond => {
          :slaves => %w[ens18f0 ens18f1]
        }
      },
      :external_ipv4 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet,
        :address => "130.117.76.9"
      },
      :external_ipv6 => {
        :interface => "bond0.2",
        :role => :external,
        :family => :inet6,
        :address => "2001:978:2:2C::172:9"
      }
    }
  },
  :postgresql => {
    :versions => ["13"],
    :settings => {
      :defaults => {
        :work_mem => "300MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :fsync => "on",
        :effective_io_concurrency => "500"
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :enable_backup => false,
    :enable_git_updates => true,
    :dbadmins => %w[lonvia tomh],
    :dbcluster => "13/main",
    :postgis => "3",
    :flatnode_file => "/ssd/nominatim/nodes.store",
    :logdir => "/ssd/nominatim/log",
    :tablespaces => {
      "dosm" => "/ssd/tablespaces/dosm",
      "iosm" => "/ssd/tablespaces/iosm",
      "dplace" => "/ssd/tablespaces/dplace",
      "iplace" => "/ssd/tablespaces/iplace",
      "daddress" => "/ssd/tablespaces/daddress",
      "iaddress" => "/ssd/tablespaces/iaddress",
      "dsearch" => "/ssd/tablespaces/dsearch",
      "isearch" => "/ssd/tablespaces/isearch",
      "daux" => "/ssd/tablespaces/daux",
      "iaux" => "/ssd/tablespaces/iaux"
    }
  }
)

run_list(
  "role[equinix]",
  "role[nominatim]"
)
