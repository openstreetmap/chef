name "logstash-forwarder"
description "Role applied to all logstash forwarders"

default_attributes(
  :apt => {
    :sources => ["elasticsearch5.x"],
  }
)

run_list(
  "recipe[logstash::forwarder]"
)
