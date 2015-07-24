name "logstash-forwarder"
description "Role applied to all logstash forwarders"

default_attributes(
  :apt => {
    :sources => ["logstash-forwarder"]
  }
)

run_list(
  "recipe[logstash::forwarder]"
)
