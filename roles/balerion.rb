name "balerion"
description "Master role applied to balerion"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "eth0",
        :role => :external,
        :inet => {
          :address => "10.5.7.35",
          :prefix => "29",
          :gateway => "10.5.7.33",
          :public_address => "23.139.196.30"
        },
        :inet6 => {
          :address => "2602:f629:0:bc::3",
          :prefix => "64",
          :gateway => "2602:f629:0:bc::1"
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :effective_cache_size => "60GB",
        :file_extend_method => "write_zeros"
      }
    }
  },
  :vectortile => {
    :rerender => {
      :lowzoom => {
        :enabled => false
      }
    },
    :replication => {
      :tileupdate => false
    }
  }
)

run_list(
  "role[pixeldeck]",
  "role[vectortile]"
)
