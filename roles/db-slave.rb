name "db-slave"
description "Role applied to all slave database servers"

default_attributes(
  :postgresql => {
    :versions => ["9.1"],
    :settings => {
      :defaults => {
        :hot_standby => "on",
        :hot_standby_feedback => "on",
        :standby_mode => "on",
        :primary_conninfo => {
          :host => "katla.ic.openstreetmap.org",
          :port => "5432",
          :user => "replication",
          :passwords => { :bag => "db", :item => "passwords" }
        },
        :restore_command => "/usr/bin/rsync katla.ic.openstreetmap.org::archive/%f %p"
      }
    }
  }
)

run_list(
  "role[db]",
  "recipe[db::slave]"
)
