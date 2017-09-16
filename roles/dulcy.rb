name "dulcy"
description "Master role applied to dulcy"

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
    :versions => ["9.6"],
    :settings => {
      :defaults => {
        :work_mem => "300MB",
        :maintenance_work_mem => "10GB",
        :random_page_cost => "1.5",
        :effective_cache_size => "60GB",
        :fsync => "on",
        :effective_io_concurrency => "3"
      }
    }
  },
  :nominatim => {
    :state => "standalone",
    :enable_backup => false,
    :enable_git_updates => false,
    :dbadmins => %w[lonvia tomh],
    :dbcluster => "9.6/main",
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
  },
  :sysfs => {
    :md_tune => {
      :comment => "Enable request merging for NVMe devices",
      :parameters => {
        "block/nvme0n1/queue/nomerges" => "1",
        "block/nvme1n1/queue/nomerges" => "1"
      }
    }
  }
)

run_list(
  "role[ic]",
  "role[nominatim]"
)
