name "thorn-05"
description "Master role applied to thorn-05"

default_attributes(
  :networking => {
    :interfaces => {
      :internal_ipv4 => {
        :interface => "bond0",
        :role => :internal,
        :family => :inet,
        :address => "10.0.32.42",
        :bond => {
          :slaves => %w(em1 em2)
        }
      }
    }
  },
  :sysctl => {
    :ipv6_autoconf => {
      :comment => "Disable IPv6 auto-configuration on internal interface",
      :parameters => {
        "net.ipv6.conf.bond0.autoconf" => "0",
        "net.ipv6.conf.bond0.accept_ra" => "0"
      }
    }
  }
)

run_list(
  "role[bm]",
  "role[web-backend]"
)
