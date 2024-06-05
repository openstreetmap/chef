name "crm"
description "Role applied to CRM server"

default_attributes(
  :accounts => {
    :users => {
      :stereo => { :status => :administrator },
      :jon => { :status => :user }
    }
  },
  :exim => {
    :local_domains => ["join.osmfoundation.org", "supporting.openstreetmap.org"],
    :routes => {
      :join_return => {
        :comment => "return@join.osmfoundation.org",
        :domains => ["join.osmfoundation.org"],
        :local_parts => ["return"],
        :maildir => "/var/mail/crm-return",
        :user => "www-data",
        :group => "mail"
      },
      :join_mail => {
        :comment => "mail@join.osmfoundation.org",
        :domains => ["join.osmfoundation.org"],
        :local_parts => ["mail"],
        :maildir => "/var/mail/crm-mail",
        :user => "www-data",
        :group => "mail"
      },
      :supporting_return => {
        :comment => "return@supporting.openstreetmap.org",
        :domains => ["supporting.osmfoundation.org"],
        :local_parts => ["return"],
        :maildir => "/var/mail/crm-return",
        :user => "www-data",
        :group => "mail"
      },
      :supporting_mail => {
        :comment => "mail@supporting.openstreetmap.org",
        :domains => ["supporting.openstreetmap.org"],
        :local_parts => ["mail"],
        :maildir => "/var/mail/crm-mail",
        :user => "www-data",
        :group => "mail"
      }
    },
    :trusted_users => ["www-data"]
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :log_bin_trust_function_creators => 1
      }
    }
  }
)

run_list(
  "recipe[civicrm]"
)
