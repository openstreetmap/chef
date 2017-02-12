name "ridley"
description "Master role applied to ridley"

default_attributes(
  :ssl => {
    :certificates => %w(osmfoundation openstreetmap)
  },
  :apache => {
    :ssl => {
      :certificate => "osmfoundation"
    }
  },
  :dhcpd => {
    :first_address => "10.0.15.1",
    :last_address => "10.0.15.254"
  },
  :munin => {
    :graphs => {
      :apcpdu_ucl => {
        :title => "Current for UCL",
        :vlabel => "Amps",
        :category => "Ups",
        :values => {
          :load => {
            :sum => ["apcpdu_apc1.load", "apcpdu_apc2.load", "apcpdu_apc3.load"],
            :label => "Load"
          }
        }
      }
    }
  },
  :networking => {
    :interfaces => {
      :external_ipv4 => {
        :interface => "eth0.2800",
        :role => :external,
        :family => :inet,
        :address => "193.60.236.19"
      },
      :internal_ipv4 => {
        :interface => "eth0.2801",
        :role => :internal,
        :family => :inet,
        :address => "10.0.0.3"
      }
    }
  },
  :openvpn => {
    :address => "10.0.16.1",
    :tunnels => {
      :ic2ucl => {
        :port => "1194",
        :mode => "client",
        :peer => {
          :host => "ironbelly.openstreetmap.org",
          :port => "1194"
        }
      },
      :shenron2ucl => {
        :port => "1195",
        :mode => "client",
        :peer => {
          :host => "shenron.openstreetmap.org",
          :port => "1194"
        }
      },
      :ucl2bm => {
        :port => "1196",
        :mode => "client",
        :peer => {
          :host => "grisu.openstreetmap.org",
          :port => "1196"
        }
      },
      :firefishy => {
        :port => "1197",
        :mode => "client",
        :peer => {
          :host => "home.firefishy.com",
          :port => "1194",
          :address => "10.0.16.201"
        }
      }
    }
  }
)

run_list(
  "role[ucl]",
  "role[hp-dl360-g6]",
  "role[gateway]",
  "role[foundation]",
  "role[stateofthemap]",
  "role[switch2osm]",
  "role[blog]",
  "role[otrs]",
  "role[donate]",
  "recipe[dhcpd]",
  "recipe[openvpn]"
)
