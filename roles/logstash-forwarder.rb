name "logstash-forwarder"
description "Role applied to all logstash forwarders"

default_attributes(
  :apt => {
    :sources => ["elasticsearch8.x"]
  }
)

run_list(
  "recipe[logstash::forwarder]"
)
