name "otrs"
description "Role applied to all OTRS servers"

default_attributes(
  :accounts => {
    :users => {
      :otrs => { :status => :role }
    }
  },
  :exim => {
    :local_domains => ["otrs.openstreetmap.org"],
    :routes => {
      :otrs_otrs => {
        :comment => "otrs@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["otrs"],
        :command => "/opt/otrs/bin/otrs.PostMaster.pl",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      },
      :otrs_data => {
        :comment => "data@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["data"],
        :command => "/opt/otrs/bin/otrs.PostMaster.pl -q 'Data Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      },
      :otrs_support => {
        :comment => "support@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["support"],
        :command => "/opt/otrs/bin/otrs.PostMaster.pl -q 'Technical Support'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/opt/otrs"
      }
    }
  },
  :otrs => {
    :site => "otrs.openstreetmap.org",
    :database_cluster => "8.4/main",
    :database_name => "otrs",
    :database_user => "otrs",
    :database_password => "otrs"
  }
)

run_list(
  "recipe[otrs]"
)
