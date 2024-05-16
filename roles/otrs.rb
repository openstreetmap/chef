name "otrs"
description "Role applied to all OTRS servers"

default_attributes(
  :exim => {
    :local_domains => ["otrs.openstreetmap.org"],
    :routes => {
      :otrs_otrs => {
        :comment => "otrs@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["otrs"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_data => {
        :comment => "data@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["data"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Data Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_membership => {
        :comment => "membership@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["membership"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Membership Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_membership_osmf_talk_owner => {
        :comment => "osmf-talk-owner@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["osmf-talk-owner"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Membership Working Group::osmf-talk'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_legal => {
        :comment => "legal@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["legal"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Licensing Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_legal_privacy => {
        :comment => "legal-privacy@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["legal-privacy"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Licensing Working Group::Privacy'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_legal_questions => {
        :comment => "legal-questions@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["legal-questions"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Licensing Working Group::Legal Questions'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_legal_trademarks => {
        :comment => "legal-trademarks@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["legal-trademarks"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Licensing Working Group::Trademarks'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_sotm_program => {
        :comment => "sotm-program@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["sotm-program"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'State of the Map:Program'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_communications => {
        :comment => "communications@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["communications"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Communications Working Group'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_communications_freebies => {
        :comment => "freebies@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["freebies"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Communications Working Group::Freebies'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      },
      :otrs_support => {
        :comment => "support@otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :local_parts => ["support"],
        :command => "/usr/share/otrs/bin/otrs.Console.pl Maint::PostMaster::Read --target-queue 'Technical Support'",
        :user => "otrs",
        :group => "www-data",
        :home_directory => "/usr/share/otrs"
      }
    }
  },
  :otrs => {
    :site => "otrs.openstreetmap.org",
    :site_aliases => ["otrs.osm.org"]
  }
)

run_list(
  "recipe[otrs]"
)
