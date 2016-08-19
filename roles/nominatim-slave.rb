name "nominatim-slave"
description "Role applied to all slave nominatim servers"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :hot_standby => "on",
        :hot_standby_feedback => "on",
        :standby_mode => "on"
      }
    }
  },
  :nominatim => {
    :state => "slave",
    :enable_backup => false
  }
)

run_list(
  "recipe[nominatim::slave]",
  "role[nominatim-base]"
)
