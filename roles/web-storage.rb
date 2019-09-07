name "web-storage"
description "Base role applied to all web/api storage servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => { :status => :role },
    },
  }
)

run_list(
  "recipe[nfs::server]"
)
