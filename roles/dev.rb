name "dev"
description "Role applied to all development servers"

default_attributes(
  :accounts => {
    :users => {
      :edgemaster => { :status => :administrator },
      :emacsen => { :status => :administrator },
      :twain => { :status => :user },
      :bretth => { :status => :user },
      :richard => { :status => :user },
      :shaunmcdonald => { :status => :user },
      :random => { :status => :user },
      :steve8 => { :status => :user },
      :blackadder => { :status => :user },
      :timsc => { :status => :user },
      :bobkare => { :status => :user },
      :daveh => { :status => :user },
      :gravitystorm => { :status => :user },
      :fred => { :status => :user },
      :nick => { :status => :user },
      :deelkar => { :status => :user },
      :simone => { :status => :user },
      :mitjak => { :status => :user },
      :htonl => { :status => :user },
      :russ => { :status => :user },
      :merio => { :status => :user },
      :chippy => { :status => :user },
      :joerichards => { :status => :user },
      :pafciu17 => { :status => :user },
      :ojw => { :status => :user },
      :harrywood => { :status => :user },
      :yellowbkpk => { :status => :user },
      :apmon => { :status => :user },
      :mackerski => { :status => :user },
      :ldp => { :status => :user },
      :mdaines => { :status => :user },
      :dan => { :status => :user },
      :ris => { :status => :user },
      :nroets => { :status => :user },
      :ollie => { :status => :user },
      :mvexel => { :status => :user },
      :tomchance => { :status => :user },
      :lfrancke => { :status => :user },
      :davidearl => { :status => :user },
      :emacsen => { :status => :user },
      :rweait => { :status => :user },
      :ant => { :status => :user },
      :milliams => { :status => :user },
      :pierzen => { :status => :user },
      :gregory => { :status => :user },
      :bsupnik => { :status => :user },
      :derick => { :status => :user },
      :joshd => { :status => :user },
      :maba => { :status => :user },
      :pnorman => { :status => :user },
      :csmale => { :status => :user },
      :jgc => { :status => :user },
      :cobra => { :status => :user },
      :ppawel => { :status => :user },
      :simon04 => { :status => :user },
      :jfire => { :status => :user },
      :malenki => { :status => :user },
      :lonvia => { :status => :user },
      :nicolas17 => { :status => :user },
      :zverik => { :status => :user },
      :ooc => { 
        :status => :role, 
        :members => [ :tomh, :blackadder, :timsc, :ollie ] 
      },
      :apis => { 
        :status => :role, 
        :members => [ :tomh ] 
      },
      :os => { 
        :status => :role, 
        :members => [ :tomh, :grant, :ollie ] 
      },
      :gpsmid => { 
        :status => :role, 
        :members => [ :apmon, :maba ] 
      }
    }
  },
  :apache => {
    :mpm => "event",
    :timeout => 30,
    :event => {
      :server_limit => 32,
      :max_clients => 800,
      :threads_per_child => 50,
      :max_requests_per_child => 10000
    }
  },
  :apt => {
    :sources => [
      "brightbox-ruby-ng",
      "ubuntugis-stable", "ubuntugis-unstable",
      "mapnik-v210"
    ]
  },
  :dev => {
    :ruby => "1.9.1",
    :rails => {
      :master => {
        :repository => "git://git.openstreetmap.org/rails.git",
        :revision => "master",
        :aliases => [ "api06.dev.openstreetmap.org" ]
      },
      :routing => {
        :repository => "git://github.com/apmon/openstreetmap-website.git",
        :revision => "routing2"
      },
      :tomh => {
        :repository => "git://github.com/tomhughes/openstreetmap-website.git",
        :revision => "next"
      },
      :owl => {
        :repository => "git://github.com/ppawel/openstreetmap-website.git",
        :revision => "owl-history-tab"
      },
      :overpass => {
        :repository => "git://github.com/drolbr/openstreetmap-website.git",
        :revision => "master"
      },
      :groups => {
        :repository => "git://github.com/osmlab/openstreetmap-website.git",
        :revision => "groups-sketch"
      },
      :welcome => {
        :repository => "git://github.com/osmlab/openstreetmap-website.git",
        :revision => "welcome-2"
      }
    }
  },
  :postgresql => {
    :versions => [ "9.1" ],
    :settings => {
      :defaults => {
        :shared_buffers => "1GB",
        :work_mem => "32MB",
        :maintenance_work_mem => "64MB",
        :max_stack_depth => "4MB",
        :effective_cache_size => "4GB"
      },
      "9.1" => {
        :port => "5433"
      }
    }
  },
  :sysctl => {
    :postgres => {
      :comment => "Increase shared memory for postgres",
      :parameters => { 
        "kernel.shmall" => "4194304",
        "kernel.shmmax" => "17179869184"
      }
    }
  }
)

run_list(
  "recipe[dev]"
)
