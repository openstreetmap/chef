name "web-backend"
description "Role applied to all web/api backend servers"

default_attributes(
  :apache => {
    :mpm => "worker",
    :worker => {
      :max_requests_per_child => 10000
    }
  },
  :logstash => {
    :forwarder => {
      :files => [
        { :paths => ["/var/log/apache2/access.log"], :fields => { :type => "apache" } },
        { :paths => ["/var/log/web/rails-logstash.log"], :fields => { :type => "rails" } }
      ]
    }
  },
  :memcached  => {
    :memory_limit => 4096
  },
  :passenger => {
    :max_pool_size => 12
  }
)

run_list(
  "role[web]",
  "role[logstash-forwarder]",
  "recipe[web::backend]"
)
