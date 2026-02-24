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
  :chef => {
    :client => {
      :cinc => true
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
  :ruby => {
    :fullstaq => true
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
  "recipe[web::frontend]"
)
