name "cmok"
description "Master role applied to cmok"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "ens3",
        :role => :external,
        :inet => {
          :address => "10.0.0.228",
          :prefix => "24",
          :gateway => "10.0.0.1",
          :public_address => "64.225.143.127"
        }
      }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :effective_cache_size => "400GB"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => {
        "kernel.shmmax" => 9 * 1024 * 1024 * 1024,
        "kernel.shmall" => 9 * 1024 * 1024 * 1024 / 4096
      }
    }
  },
  :vectortile => {
    :replication => {
      :enabled => false,
      :tileupdate => false
    },
    :spirit => {
      :version => "7c68ecdd82606fd64dfe6e2ba7a1f1741afcc34c"
    }
  }
)

run_list(
  "role[cloudferro-waw3-2]",
  "role[vectortile]"
)
