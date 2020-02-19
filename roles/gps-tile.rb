name "gps-tile"
description "Role applied to all GPS tile servers"

default_attributes(
  :accounts => {
    :users => {
      :enf => { :status => :administrator },
      :gpstile => {
        :members => [:enf, :tomh]
      }
    }
  },
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
  }
)

run_list(
  "recipe[gps-tile]"
)
