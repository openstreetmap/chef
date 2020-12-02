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
      :dodobas => { :status => :user },
      :mhohmann => { :status => :user },
      :enelson => { :status => :user },
      :gregrs => { :status => :user },
      :stereo => { :status => :user },
      :dmlu => { :status => :user },
      :ooc => {
        :status => :role,
        :members => [:tomh, :blackadder, :timsc, :ollie]
      },
      :apis => {
        :status => :role,
        :members => [:tomh]
      },
      :os => {
        :status => :role,
        :members => [:tomh, :grant, :ollie]
      },
      :gpsmid => {
        :status => :role,
        :members => [:apmon, :maba]
      }
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
  :dev => {
    :rails => {
      :master => {
        :repository => "https://git.openstreetmap.org/public/rails.git",
        :revision => "master",
        :cgimap_repository => "https://github.com/zerebubuth/openstreetmap-cgimap.git",
        :cgimap_revision => "master",
        :aliases => ["api06.dev.openstreetmap.org"]
      },
      :tomh => {
        :repository => "https://github.com/tomhughes/openstreetmap-website.git",
        :revision => "next"
      },
      :comments => {
        :repository => "https://github.com/ukasiu/openstreetmap-website.git",
        :revision => "comments_list"
      },
      :locale => {
        :repository => "https://github.com/tomhughes/openstreetmap-website.git",
        :revision => "locale"
      },
      :microcosms => {
        :repository => "https://github.com/openbrian/osm-microcosms.git",
        :revision => "microcosms"
      },
      :upload => {
        :repository => "https://git.openstreetmap.org/public/rails.git",
        :revision => "master",
        :cgimap_repository => "https://github.com/zerebubuth/openstreetmap-cgimap.git",
        :cgimap_revision => "feature/bulk_upload"
      }
    }
  },
  :postgresql => {
    :versions => ["12"],
    :settings => {
      :defaults => {
        :shared_buffers => "1GB",
        :work_mem => "32MB",
        :maintenance_work_mem => "64MB",
        :max_stack_depth => "4MB",
        :effective_cache_size => "4GB"
      },
      "12" => {
        :port => "5432",
        :wal_level => "logical",
        :max_replication_slots => "1"
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
