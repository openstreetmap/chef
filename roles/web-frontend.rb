name "web-frontend"
description "Role applied to all web/api frontend servers"

default_attributes(
  :apache => {
    :mpm => "event",
    :evasive => {
      :page_count => 100,
      :site_count => 100,
      :blocking_period => 30,
      :enable => false
    },
    :event => {
      :server_limit => 20,
      :max_request_workers => 1000,
      :threads_per_child => 50,
      :min_spare_threads => 50,
      :max_spare_threads => 450,
      :async_request_worker_factor => 4
    }
  },
  :logstash => {
    :forwarder => {
      "filebeat.inputs" => [
        { "type" => "filestream", "id" => "apache", "paths" => ["/var/log/apache2/access.log"], "fields" => { "type" => "apache" }, "fields_under_root" => true },
        { "type" => "filestream", "id" => "rails", "paths" => ["/var/log/web/rails-logstash.log"], "fields" => { "type" => "rails" }, "fields_under_root" => true }
      ]
    }
  },
  :memcached => {
    :memory_limit => 8192
  },
  :networking => {
    :firewall => {
      :http_rate_limit => "s:5/sec:30"
    }
  },
  :passenger => {
    :max_pool_size => 50
  },
  :exim => {
    :local_domains => ["messages.openstreetmap.org"],
    :routes => {
      :messages => {
        :comment => "messages.openstreetmap.org",
        :domains => ["messages.openstreetmap.org"],
        :local_parts => ["${lookup{$local_part}lsearch*,ret=key{/etc/exim4/detaint}}"],
        :command => "/usr/local/bin/deliver-message $local_part_data",
        :user => "rails",
        :group => "rails",
        :home_directory => "/srv/www.openstreetmap.org/rails",
        :path => "/bin:/usr/bin:/usr/local/bin",
        :case_sensitive => true
      }
    }
  }
)

run_list(
  "role[web]",
  "role[logstash-forwarder]",
  "recipe[web::frontend]"
)
