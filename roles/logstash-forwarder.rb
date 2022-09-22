name "logstash-forwarder"
description "Role applied to all logstash forwarders"

run_list(
  "recipe[logstash::forwarder]"
)
