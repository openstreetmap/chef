name "nominatim-slave"
description "Role applied to all slave nominatim servers"

default_attributes(
  :postgresql => {
    :versions => ["9.3"],
    :settings => {
      :defaults => {
        :hot_standby => "on",
        :hot_standby_feedback => "on",
        :standby_mode => "on",
        :primary_conninfo => {
          :host => "pummelzacken.ucl.openstreetmap.org",
          :port => "5432",
          :user => "replication",
          :passwords => { :bag => "nominatim", :item => "passwords" }
        },
        :restore_command => "/usr/bin/rsync pummelzacken.ucl.openstreetmap.org::archive/%f %p"
      }
    }
  },
  :nominatim => {
    :enable_backup => false
  }
)

run_list(
  "role[nominatim]",
  "recipe[nominatim::slave]"
)
