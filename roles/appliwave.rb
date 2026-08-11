name "appliwave"
description "Role applied to all servers at Appliwave"

default_attributes(
  :accounts => {
    :users => {
      :appliwave => { :status => :administrator }
    }
  },
  :hosted_by => "Appliwave",
  :location => "Croissy-Beaubourg, France"
)

override_attributes(
  :networking => {
    :nameservers => ["185.73.206.93", "185.73.206.94"]
  }
)

run_list(
  "role[fr]"
)
