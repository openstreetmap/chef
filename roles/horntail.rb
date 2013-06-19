name "horntail"
description "Master role applied to horntail"

default_attributes(
  :accounts => {
    :users => {
      :gravitystorm => { :status => :user }
    }
  },
  :munin => {
    :plugins => {
      :ipmi_fans => {
        :FAN1 => { :graph => "no" },
        :FAN2 => { :graph => "no" },
        :FAN3 => { :graph => "no" },
        :FAN4 => { :graph => "no" },
        :FAN5 => { :graph => "no" }
      },
      :sensors_fan => {
        :fan1 => { :graph => "no" },
        :fan2 => { :graph => "no" },
        :fan3 => { :graph => "no" },
        :fan4 => { :graph => "no" },
        :fan5 => { :graph => "no" },
        :fan6 => { :graph => "no" },
        :fan9 => { :graph => "no" },
        :fan10 => { :graph => "no" }
      },
      :sensors_volt => {
        :contacts => "null",
        :volt1 => {
          :warning => "1.316:1.484",
          :critical => "1.26:1.54"
        },
        :volt3 => {
          :warning => "1.1:2.0",
          :critical => "1.0:3.0"
        },
         :volt4 => {
          :warning => "11.0:13.0",
          :critical => "10.5:13.5"
        }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet,
        :address => "193.63.75.101"
      },
      :external_ipv6 => {
        :interface => "eth0",
        :role => :external,
        :family => :inet6,
        :address => "2001:630:12:500:202:b3ff:feec:eeac"
      },
      :internal_ipv4 => {
        :interface => "eth1",
        :role => :internal,
        :family => :inet,
        :address => "146.179.159.164"
      }
    }
  },
  :openvpn => {
    :address => "10.0.16.2",
    :tunnels => {
      :ic2ucl => {
        :port => "1194",
        :mode => "server",
        :peer => {
          :host => "ridley.openstreetmap.org"
        }
      }
    }
  },
  :rsyncd => {
    :modules => {
      :hosts => {
        :comment => "Host data",
        :path => "/home/hosts",
        :read_only => true,
        :write_only => false,
        :list => false,
        :uid => "tomh",
        :gid => "tomh",
        :transfer_logging => false,
        :hosts_allow => [ 
          "89.16.179.150",                       # shenron
          "2001:41c8:10:996:21d:7dff:fec3:df70", # shenron
          "212.159.112.221"                      # grant
        ]
      },
      :logs => {
        :comment => "Log files",
        :path => "/store/logs",
        :read_only => false,
        :write_only => true,
        :list => false,
        :uid => "www-data",
        :gid => "www-data",
        :transfer_logging => false,
        :hosts_allow => [
          "128.40.168.0/24",      # ucl external
          "146.179.159.160/27",   # ic internal
          "193.63.75.96/27",      # ic external
          "2001:630:12:500::/64", # ic external
          "127.0.0.0/8",          # localhost
          "::1"                   # localhost
        ]
      },
      :backup => {
        :comment => "Backups",
        :path => "/store/backup",
        :read_only => false,
        :write_only => true,
        :list => false,
        :uid => "osmbackup",
        :gid => "osmbackup",
        :transfer_logging => false,
        :hosts_allow => [
          "128.40.168.0/24",      # ucl external
          "146.179.159.160/27",   # ic internal
          "193.63.75.96/27",      # ic external
          "2001:630:12:500::/64", # ic external
          "127.0.0.0/8",          # localhost
          "::1"                   # localhost
        ]
      }
    }
  }
);

run_list(
  "role[ic]",
  "role[gateway]",
  "role[chef-server]",
  "role[chef-repository]",
  "role[planet]",
  "role[stats]",
  "role[web-storage]",
  "recipe[rsyncd]",
  "recipe[openvpn]"
)
