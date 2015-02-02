name "base"
description "Base role applied to all servers"

default_attributes(
  :accounts => {
    :users => {
      :grant => { :status => :administrator },
      :tomh => { :status => :administrator },
      :matt => { :status => :administrator },
      :jburgess => { :status => :administrator }
    }
  },
  :apt => {
    :sources => [ "openstreetmap" ]
  },
  :networking => {
    :roles => {
      :internal => { :metric => 200, :zone => "loc" },
      :external => { :metric => 100 }
    },
    :search => [ "openstreetmap.org" ]
  },
  :sysctl => {
    :panic => {
      :comment => "Reboot automatically after a panic",
      :parameters => { "kernel.panic" => "60" }
    },
    :blackhole => {
      :comment => "Do TCP level MTU probing if we seem to have an ICMP blackhole",
      :parameters => { "net.ipv4.tcp_mtu_probing" => "1" }
    },
    :network_buffers => {
      :comment => "Tune network buffers",
      :parameters => {
        "net.core.rmem_max" => "16777216",
        "net.core.wmem_max" => "16777216",
        "net.ipv4.tcp_rmem" => "4096\t87380\t16777216",
        "net.ipv4.tcp_wmem" => "4096\t65536\t16777216"
      }
    },
    :network_backlog => {
      :comment => "Increase maximum backlog for incoming network packets",
      :parameters => { "net.core.netdev_max_backlog" => "2500" }
    },
    :network_conntrack_established => {
      :comment => "Only track established connections for four hours",
      :parameters => {
        "net.netfilter.nf_conntrack_tcp_timeout_established" => "14400"
      }
    },
    :tcp_syncookies => {
      :comment => "Turn on syncookies to protect against SYN floods",
      :parameters => {
        "net.ipv4.tcp_syncookies" => "1"
      }
    }
  },
  :sysfs => {
    :cpufreq_ondemand => {
      :comment => "Tune the ondemand CPU frequency governor",
      :parameters => {
        "devices/system/cpu/cpufreq/ondemand/up_threshold" => "25",
        "devices/system/cpu/cpufreq/ondemand/sampling_down_factor" => "100"
      }
    }
  }
)

run_list(
  "recipe[accounts]",
  "recipe[apt]",
  "recipe[chef]",
  "recipe[devices]",
  "recipe[hardware]",
  "recipe[munin]",
  "recipe[networking]",
  "recipe[exim]",
  "recipe[ntp]",
  "recipe[openssh]",
  "recipe[sysctl]",
  "recipe[sysfs]",
  "recipe[tools]",
  "recipe[fail2ban]"
)
