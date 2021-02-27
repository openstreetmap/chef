name "logstash-forwarder"
description "Role applied to all logstash forwarders"

default_attributes(
  :apt => {
    :sources => ["elasticsearch6.x"]
  }
)

run_list(
  "recipe[logstash::forwarder]"
)
