name "web-frontend"
description "Role applied to all web/api frontend servers"

default_attributes(
  :apache => {
    :mpm => "event",
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
      "filebeat.prospectors" => [
        { "input_type" => "log", "paths" => ["/var/log/apache2/access.log"], "fields" => { "type" => "apache" } },
        { "input_type" => "log", "paths" => ["/var/log/web/rails-logstash.log"], "fields" => { "type" => "rails" } }
      ]
    }
  },
  :memcached => {
    :memory_limit => 4096
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
        :command => "/usr/local/bin/passenger-ruby /srv/www.openstreetmap.org/rails/script/deliver-message $local_part",
        :user => "rails",
        :group => "rails",
        :home_directory => "/srv/www.openstreetmap.org/rails",
        :path => "/bin:/usr/bin:/usr/local/bin",
        :environment => {
          "RAILS_ENV" => "production"
        }
      }
    }
  }
)

run_list(
  "role[web]",
  "role[logstash-forwarder]",
  "recipe[web::frontend]"
)
