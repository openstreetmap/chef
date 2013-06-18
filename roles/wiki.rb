name "wiki"
description "Role applied to all wiki servers"

default_attributes(
  :accounts => {
    :users => {
      :wiki => { :status => :role }
    }
  },
  :exim => {
    :trusted_users => [ "www-data" ],
    :aliases => {
      :root => "grant"
    }
  },
  :memcached => {
    :tcp_port => 11000,
    :udp_port => 11000,
    :memory_limit => 512,
    :connection_limit => 8192,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  }
)

run_list(
  "recipe[mediawiki]"
)
