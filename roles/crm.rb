name "crm"
description "Role applied to CRM server"


default_attributes(
  :exim => {
    :local_domains => [ "crm.osmfoundation.org" ],
    :routes => {
      :crm_return => {
        :comment => "return@crm.osmfoundation.org",
        :domains => [ "crm.osmfoundation.org" ],
        :local_parts => [ "return" ],
        :maildir => "/var/mail/crm-return",
        :user => "www-data",
        :group => "mail"
      },
      :crm_mail => {
        :comment => "mail@crm.osmfoundation.org",
        :domains => [ "crm.osmfoundation.org" ],
        :local_parts => [ "mail" ],
        :maildir => "/var/mail/crm-mail",
        :user => "www-data",
        :group => "mail"
      }
    }
  }
)

run_list(
  "recipe[civicrm]"
)
