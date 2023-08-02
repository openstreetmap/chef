name "crm-staging"
description "Role applied to CRM staging server"

default_attributes(
  :accounts => {
    :users => {
      :stereo => { :status => :administrator }
    }
  },
  :exim => {
    # :local_domains => ["join.osmfoundation.org"],
    # :routes => {
    #   :join_return => {
    #     :comment => "return@join.osmfoundation.org",
    #     :domains => ["join.osmfoundation.org"],
    #     :local_parts => ["return"],
    #     :maildir => "/var/mail/crm-return",
    #     :user => "www-data",
    #     :group => "mail"
    #   },
    #   :join_mail => {
    #     :comment => "mail@join.osmfoundation.org",
    #     :domains => ["join.osmfoundation.org"],
    #     :local_parts => ["mail"],
    #     :maildir => "/var/mail/crm-mail",
    #     :user => "www-data",
    #     :group => "mail"
    #   }
    # },
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
  "recipe[civicrm-staging]"
)
