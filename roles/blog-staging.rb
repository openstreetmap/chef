name "blog-staging"
description "Role applied to staging blog servers"

default_attributes(
  :accounts => {
    :users => {
      :mikel => { :status => :administrator },
      :wordpress => {
        :status => :role,
        :members => [:mikel]
      }
    },
  }
)

run_list(
  "recipe[blog::staging]"
)
