name "wiki"
description "Role applied to all wiki servers"

default_attributes(
  :accounts => {
    :users => {
      :wiki => { :status => :role }
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 30,
    :event => {
      :server_limit => 32,
      :max_request_workers => 800,
      :threads_per_child => 50,
      :max_connections_per_child => 10000
    }
  },
  :elasticsearch => {
    :version => "5.x",
    :cluster => {
      :name => "wiki"
    }
  },
  :exim => {
    :trusted_users => ["www-data"],
    :aliases => {
      :root => "grant"
    },
    :rewrites => [
      {
        :pattern => "www-data@openstreetmap.org",
        :replacement => "wiki@noreply.openstreetmap.org",
        :flags => "F"
      }
    ]
  },
  :memcached => {
    :memory_limit => 1024,
    :connection_limit => 8192,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_buffer_pool_size => "4G",
        :key_buffer_size => "64M",
        :max_connections => "200",
        :sort_buffer_size => "8M",
        :tmp_table_size => "128M"
      }
    }
  }
)

run_list(
  "role[elasticsearch]",
  "recipe[wiki]"
)
