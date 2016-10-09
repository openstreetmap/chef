name "unizar"
description "Role applied to all servers at University of Zaragoza"

default_attributes(
  :accounts => {
    :users => {
    }
  },
  :hosted_by => "University of Zaragoza",
  :location => "Zaragoza, Spain",
  :networking => {
    :nameservers => ["155.210.12.9", "155.210.3.12"],
    :roles => {
      :external => {
        :zone => "uz"
      }
    }
  }
)

run_list(
  "role[es]"
)
