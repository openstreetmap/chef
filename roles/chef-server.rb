name "chef-server"
description "Role applied to all chef servers"

default_attributes(
  :munin => {
    :plugins => {
      :chef_status => {
        :ascalon => { :warning => ":", :critical => ":" },
        :idris => { :warning => ":", :critical => ":" },
        :norbert => { :warning => ":", :critical => ":" },
        :smaug => { :warning => ":", :critical => ":" },
        :zark => { :warning => ":", :critical => ":" }
      }
    }
  }
)

run_list(
  "recipe[chef::server]"
)
