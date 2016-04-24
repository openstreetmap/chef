name "thorn-03"
description "Master role applied to thorn-03"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "eth0",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.167"
      }
    }
  },
  :sysctl => {
    :ipv6_autoconf => {
      :comment => "Disable IPv6 auto-configuration on internal interface",
      :parameters => {
        "net.ipv6.conf.eth0.autoconf" => "0",
        "net.ipv6.conf.eth0.accept_ra" => "0"
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
