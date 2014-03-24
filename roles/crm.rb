name "crm"
description "Role applied to CRM server"


default_attributes(
  :exim => {
    :local_domains => [ "crm.osmfoundation.org" ],
    :routes => {
      :crm => {
        :comment => "crm.osmfoundation.org",
        :domains => [ "crm.osmfoundation.org" ],
        :maildir => "/var/mail/crm",
        :user => "wordpress",
        :group => "mail"
      }
    }
  }
)

run_list(
  "recipe[civicrm]"
)
