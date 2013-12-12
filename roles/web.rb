name "web"
description "Role applied to all web/api servers"

default_attributes(
  :accounts => {
    :users => {
      :rails => {
        :status => :role,
        :members => [ :tomh, :grant ]
      }
    }
  },
  :apt => {
    :sources => [ "brightbox-ruby-ng" ]
  },
  :nfs => {
    "/store/rails" => { :host => "ironbelly", :path => "/store/rails" }
  },
  :web => {
    :status => "online",
    :database_host => "db"
  }
)

run_list(
  "recipe[nfs]"
)
