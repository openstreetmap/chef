name "crm"
description "Role applied to CRM server"

default_attributes(
  :accounts => {
    :users => {
      :stereo => { :status => :administrator }
    }
  },
  :exim => {
    :local_domains => ["join.osmfoundation.org"],
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
      }
    },
    :trusted_users => ["www-data"]
  },
  :mysql => {
    :settings => {
      :mysqld => {
        :innodb_strict_mode => true,
        :innodb_file_per_table => true,
        :innodb_file_format => "Barracuda"
      }
    }
  }
)

run_list(
  "recipe[civicrm]"
)
