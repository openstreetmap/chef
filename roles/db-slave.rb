name "db-slave"
description "Role applied to all slave database servers"

default_attributes(
  :postgresql => {
    :settings => {
      :defaults => {
        :hot_standby => "on",
        :hot_standby_feedback => "on",
        :standby_mode => "on",
        :primary_conninfo => {
          :host => "snap-01.ams.openstreetmap.org",
          :port => "5432",
          :user => "replication",
          :passwords => { :bag => "db", :item => "passwords" }
        },
        :restore_command => "/bin/pgbackrest --stanza=main archive-get %f %p"
      }
    }
  }
)

run_list(
  "role[db]",
  "recipe[db::slave]"
)
