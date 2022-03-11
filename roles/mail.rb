name "mail"
description "Role applied to all mail servers"

default_attributes(
  :exim => {
    :local_domains => [
      "openstreetmap.org",
      "osm.org",
      "noreply.openstreetmap.org",
      "openstreetmap.co.uk",
      "openstreetmap.org.uk",
      "openstreetmap.com",
      "openstreetmap.io",
      "openstreetmap.pro",
      "openstreetmaps.org",
      "osm.io"
    ],
    :daemon_smtp_ports => [25, 26],
    :certificate_names => [
      "mail.openstreetmap.org",
      "a.mx.openstreetmap.org",
      "a.mx.osm.org",
      "a.mx.openstreetmap.com",
      "a.mx.openstreetmap.io",
      "a.mx.openstreetmap.pro",
      "a.mx.openstreetmaps.org",
      "a.mx.osm.io"
    ],
    :queue_run_max => 25,
    :smtp_accept_max => 200,
    :smarthost_name => "mail.openstreetmap.org",
    :smarthost_via => false,
    :dns_blacklists => ["zen.spamhaus.org"],
    :routes => {
      :messages => {
        :comment => "messages.openstreetmap.org",
        :domains => ["messages.openstreetmap.org"],
        :host => ["spike-06.openstreetmap.org", "spike-07.openstreetmap.org", "spike-08.openstreetmap.org"]
      },
      :otrs => {
        :comment => "otrs.openstreetmap.org",
        :domains => ["otrs.openstreetmap.org"],
        :host => "ridley.ucl.openstreetmap.org"
      },
      :join => {
        :comment => "join.osmfoundation.org",
        :domains => ["join.osmfoundation.org"],
        :host => "ridley.ucl.openstreetmap.org"
      },
      :community => {
        :comment => "community.openstreetmap.org",
        :domains => ["community.openstreetmap.org"],
        :host => "jakelong.dub.openstreetmap.org::2500"
      }
    },
    :dkim_selectors => {
      "openstreetmap.org" => "20200301",
      "osmfoundation.org" => "20201112"
    },
    :aliases => {
      "abuse" => "root",
      "postmaster" => "root",
      "webmaster" => "support",
      "clamav" => "root",
      "rails" => "root",
      "trac" => "root",
      "munin" => "root",
      "prometheus" => "root",
      "www-data" => "root",
      "osmbackup" => "root",
      "noreply" => "/dev/null",
      "bounces" => "/dev/null",
      "wishlist" => "/dev/null",
      "treasurer" => "treasurer@osmfoundation.org",
      "donations" => "treasurer@osmfoundation.org",
      "secretary" => "secretary@osmfoundation.org",
      "chairman" => "chairman@osmfoundation.org",
      "accountant" => "accountant@osmfoundation.org",
      "data" => "data@otrs.openstreetmap.org",
      "otrs" => "otrs@otrs.openstreetmap.org",
      "support" => "support@otrs.openstreetmap.org",
      "memorial" => "communication@osmfoundation.org",
      "legal" => "legal@osmfoundation.org",
      "dmca" => "dmca@osmfoundation.org",
      "program-sotm" => "sotm-program@otrs.openstreetmap.org"
    },
    :private_aliases => "mail"
  },
  :munin => {
    :plugins => {
      :exim_mailqueue => {
        :mails => {
          :warning => 500,
          :critical => 1000
        }
      }
    }
  },
  :prometheus => {
    :metrics => {
      :exim_queue_limit => { :metric => 250 }
    }
  }
)

run_list(
  "recipe[clamav]",
  "recipe[exim]",
  "recipe[spamassassin]"
)
