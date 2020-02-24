name "logstash"
description "Role applied to all logstash servers"

default_attributes(
  :kibana => {
    :sites => {
      :logstash => {
        :site => "logstash.openstreetmap.org",
        :port => 5601,
        :elasticsearch_url => "http://127.0.0.1:9200/"
      }
    }
  }
)

run_list(
  "role[elasticsearch]",
  "role[kibana]",
  "recipe[logstash]"
)
