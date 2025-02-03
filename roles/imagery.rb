name "imagery"
description "Role applied to all imagery servers"

default_attributes(
  :accounts => {
    :users => {
      :dmlu => { :status => :user },
      :htonl => { :status => :user },
      :stereo => { :status => :administrator },
      :imagery => {
        :status => :role,
        :members => [:grant, :tomh, :dmlu, :htonl, :stereo ]
      }
    }
  },
  :sysctl => {
    :sockets => {
      :comment => "Increase size of connection queue",
      :parameters => {
        "net.core.somaxconn" => 10000
      }
    }
  },
  :nginx => {
    :cache => {
      :fastcgi => {
        :enable => true,
        :keys_zone => "fastcgi_cache_zone:256M",
        :inactive => "45d",
        :max_size => "51200M"
      }
    }
  }
)

run_list(
  "recipe[imagery::au_agri]",
  "recipe[imagery::au_act_aerial]",
  "recipe[imagery::au_vic_melbourne_aerial]",
  "recipe[imagery::gb_ea]",
  "recipe[imagery::gb_hampshire_aerial]",
  "recipe[imagery::gb_os_sv]",
  "recipe[imagery::gb_surrey_aerial]",
  "recipe[imagery::za_ngi_topo]",
  "recipe[imagery::za_coct_aerial]",
  "recipe[imagery::na_sgswa_topo]",
  "recipe[imagery::lu_ngl_dtm]",
  "recipe[imagery::lu_lidar_hillshade]",
  "recipe[imagery::za_ngi_aerial]",
  "recipe[imagery::us_imagery]"
)
