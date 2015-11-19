name "thorn-01"
description "Master role applied to thorn-01"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.165"
      }
    }
  },
  :web => {
    :readonly_database_host => "db-slave"
  }
)

run_list(
  "role[ic]",
  "role[hp-g5]",
  "role[web-backend]"
)
