name "dev"
description "Role applied to all development servers"

default_attributes(
  :accounts => {
    :users => {
      :ant => { :status => :user },
      :antonkh => { :status => :user },
      :apmon => { :status => :user },
      :blackadder => { :status => :user },
      :bobkare => { :status => :user },
      :bretth => { :status => :user },
      :bsupnik => { :status => :user },
      :chippy => { :status => :user },
      :cobra => { :status => :user },
      :contrapunctus => { :status => :user },
      :csmale => { :status => :user },
      :dan => { :status => :user },
      :daveh => { :status => :user },
      :davidearl => { :status => :user },
      :deelkar => { :status => :user },
      :derick => { :status => :user },
      :dmlu => { :status => :user },
      :dodobas => { :status => :user },
      :edgemaster => { :status => :administrator },
      :emacsen => { :status => :user },
      :enelson => { :status => :user },
      :fred => { :status => :user },
      :gmoncrieff => { :status => :user },
      :gravitystorm => { :status => :user },
      :gregory => { :status => :user },
      :gregrs => { :status => :user },
      :harrywood => { :status => :user },
      :htonl => { :status => :user },
      :jeslop => { :status => :user },
      :jfire => { :status => :user },
      :jgc => { :status => :user },
      :joerichards => { :status => :user },
      :joshd => { :status => :user },
      :ldp => { :status => :user },
      :lfrancke => { :status => :user },
      :ligfietser => { :status => :user },
      :lonvia => { :status => :user },
      :maba => { :status => :user },
      :mackerski => { :status => :user },
      :malenki => { :status => :user },
      :mdaines => { :status => :user },
      :merio => { :status => :user },
      :mhohmann => { :status => :user },
      :milliams => { :status => :user },
      :mitjak => { :status => :user },
      :msbarry => { :status => :user },
      :mvexel => { :status => :user },
      :nick => { :status => :user },
      :nicolas17 => { :status => :user },
      :nroets => { :status => :user },
      :ojw => { :status => :user },
      :ollie => { :status => :user },
      :pafciu17 => { :status => :user },
      :pierzen => { :status => :user },
      :pnorman => { :status => :user },
      :ppawel => { :status => :user },
      :random => { :status => :user },
      :richard => { :status => :user },
      :rtnf => { :status => :user },
      :ris => { :status => :user },
      :russ => { :status => :user },
      :rweait => { :status => :user },
      :shaunmcdonald => { :status => :user },
      :simon04 => { :status => :user },
      :simone => { :status => :user },
      :stereo => { :status => :user },
      :steve8 => { :status => :user },
      :timsc => { :status => :user },
      :tomchance => { :status => :user },
      :twain => { :status => :user },
      :yellowbkpk => { :status => :user },
      :zander => { :status => :user },
      :zverik => { :status => :user },
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
      },
      :"za-imagery" => {
          :status => :role,
          :members => [:grant, :htonl, :gmoncrieff, :zander]
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
        :revision => "next",
        :cgimap_repository => "https://github.com/zerebubuth/openstreetmap-cgimap.git",
        :cgimap_revision => "master"
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
      :signup => {
        :repository => "https://github.com/milan-cvetkovic/openstreetmap-website.git",
        :revision => "issue_4128_login_signup"
      }
    }
  },
  :postgresql => {
    :versions => ["15"],
    :settings => {
      :defaults => {
        :max_connections => "500",
        :shared_buffers => "1GB",
        :work_mem => "32MB",
        :maintenance_work_mem => "64MB",
        :max_stack_depth => "4MB",
        :effective_cache_size => "4GB"
      },
      "15" => {
        :port => "5432",
        :wal_level => "logical"
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
  },
  :openssh => {
    :password_authentication => true
  }
)

run_list(
  "recipe[dev]"
)
