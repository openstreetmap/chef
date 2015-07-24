name "logstash"
description "Role applied to all logstash servers"

default_attributes(
  :apt => {
    :sources => ["logstash"]
  },
  :elasticsearch => {
    :cluster => {
      :name => "logstash"
    }
  }
)

run_list(
  "role[elasticsearch]",
  "recipe[logstash]"
)
