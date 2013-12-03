name "db-backup"
description "Role applied to the server responsible for database backups"

default_attributes(
  :accounts => {
    :users => {
      :osmbackup => { :status => :role }
    }
  },
  :postgresql => {
    :settings => {
      :defaults => {
        :user_name_maps => {
          :backup => [
            { :system => "osmbackup", :postgres => "backup" }
          ]
        },
        :early_authentication_rules => [
          { :type => "local", :database => "all", :user => "backup", :method => "peer", :options => { :map => "backup" } }
        ]
      }
    }
  }
)

run_list(
  "recipe[db::backup]"
)
