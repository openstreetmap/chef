name "blog-staging"
description "Role applied to staging blog servers"

default_attributes(
  :accounts => {
    :users => {
      :mikel => { :status => :administrator }
    },
    :groups => {
      :wordpress => {
        :members => [:mikel]
      }
    },
  }
)

run_list(
  "recipe[blog::staging]"
)
