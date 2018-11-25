name "otrs"
description "Role applied to all OTRS servers"

default_attributes(
  :accounts => {
    :users => {
      :otrs => { :status => :role }
    },
    :groups => {
      :"www-data" => {
        :members => [:otrs]
      }
    }
  },
  :exim => {
    :local_domains => ["otrs.openstreetmap.org"],
    :routes => {
      :otrs_otrs => {
        :comment => "otrs@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["otrs"],
        :command => "/opt/otrs/bin/otrs.Console.pl Maint::PostMaster::Read",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      },
      :otrs_data => {
        :comment => "data@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["data"],
        :command => "/opt/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Data Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      },
      :otrs_membership => {
        :comment => "membership@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["membership"],
        :command => "/opt/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Membership Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      },
      :otrs_support => {
        :comment => "support@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["support"],
        :command => "/opt/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Technical Support'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      }
    }
  },
  :otrs => {
    :site => "otrs.openstreetmap.org",
    :site_aliases => ["otrs.osm.org"],
    :database_cluster => "10/main",
    :database_name => "otrs",
    :database_user => "otrs",
    :database_password => "otrs"
  },
  :postgresql => {
    :versions => ["10"]
  }
)

run_list(
  "recipe[otrs]"
)
