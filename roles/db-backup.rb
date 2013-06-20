name "db-backup"
description "Role applied to the server responsible for database backups"

default_attributes(
  :accounts => {
    :users => {
      :osmbackup => { :status => :role }
    }
  }
)

run_list(
  "recipe[db::backup]"
)
