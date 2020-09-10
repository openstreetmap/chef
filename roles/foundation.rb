name "foundation"
description "Role applied to all OSMF servers"

default_attributes(
  :apt => {
    :sources => ["passenger"]
  },
  :elasticsearch => {
    :version => "5.x",
    :cluster => {
      :name => "foundation"
    }
  },
  :memcached => {
    :memory_limit => 400,
    :chunk_growth_factor => 1.05,
    :min_item_size => 5
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_buffer_pool_size => "512M",
        :key_buffer_size => "64M",
        :max_connections => "200",
        :query_cache_size => "48M",
        :query_cache_type => "1",
        :sort_buffer_size => "8M",
        :tmp_table_size => "48M"
      }
    }
  }
)

run_list(
  "role[crm]",
  "role[elasticsearch]",
  "recipe[foundation::wiki]",
  "recipe[foundation::board]",
  "recipe[foundation::dwg]",
  "recipe[foundation::mwg]",
  "recipe[foundation::owg]"
)
