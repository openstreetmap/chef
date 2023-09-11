default[:civicrm][:version] = "5.65.1"

# was used for SotM
# default[:civicrm][:extensions][:cividiscount][:name] = "org.civicrm.module.cividiscount"
# default[:civicrm][:extensions][:cividiscount][:repository] = "https://lab.civicrm.org/extensions/cividiscount.git"
# default[:civicrm][:extensions][:cividiscount][:revision] = "3.8.8"

# used to email people from civicrm
default[:civicrm][:extensions][:emailapi][:name] = "org.civicoop.emailapi"
default[:civicrm][:extensions][:emailapi][:repository] = "https://lab.civicrm.org/extensions/emailapi.git"
default[:civicrm][:extensions][:emailapi][:revision] = "2.9"

# fancy email templates - INSTALL MANUALLY, NOT FROM GIT
default[:civicrm][:extensions][:mosaico][:name] = "uk.co.vedaconsulting.mosaico"
default[:civicrm][:extensions][:mosaico][:zip] = "https://download.civicrm.org/extension/uk.co.vedaconsulting.mosaico/3.2.1691060437/uk.co.vedaconsulting.mosaico-3.2.1691060437.zip"

# validate that osm username exists, simple check
default[:civicrm][:extensions][:username][:name] = "org.openstreetmap.username"
default[:civicrm][:extensions][:username][:repository] = "https://github.com/grischard/org.openstreetmap.username.git"
default[:civicrm][:extensions][:username][:revision] = "ac86edbe29cf076cd956507ac6cec4bf6c5a137d"

# do not send report emails if daily report is empty (mwg)
default[:civicrm][:extensions][:donotsendreportemail][:name] = "org.civicrm.donotsendreportemail"
default[:civicrm][:extensions][:donotsendreportemail][:repository] = "https://github.com/pradpnayak/org.civicrm.donotsendreportemail.git"
default[:civicrm][:extensions][:donotsendreportemail][:revision] = "3b31c2e0c62183872c7ecd244395fb8dcfbd5dbb"

# make civicrm look nicer
default[:civicrm][:extensions][:shoreditch][:name] = "org.civicrm.shoreditch"
default[:civicrm][:extensions][:shoreditch][:repository] = "https://github.com/civicrm/org.civicrm.shoreditch.git"
default[:civicrm][:extensions][:shoreditch][:revision] = "1.0.0-beta.12"

# extra rules for membership renewal
default[:civicrm][:extensions][:membershipextra][:name] = "com.skvare.membershipextra"
default[:civicrm][:extensions][:membershipextra][:repository] = "https://github.com/Skvare/com.skvare.membershipextra.git"
default[:civicrm][:extensions][:membershipextra][:revision] = "41edc3c04d49987006500b7426b38c12470446b3"

# Verify active contributor status
default[:civicrm][:extensions][:osmfverifycontributor][:name] = "osmf-verify-contributor"
default[:civicrm][:extensions][:osmfverifycontributor][:repository] = "https://github.com/openstreetmap/osmf-verify-contributor.git"
default[:civicrm][:extensions][:osmfverifycontributor][:revision] = "bb0cd61783033fb2e108c30e47224e5a818987f8"

# Pay with Mollie
default[:civicrm][:extensions][:omnipay][:name] = "nz.co.fuzion.omnipaymultiprocessor"
default[:civicrm][:extensions][:omnipay][:repository] = "https://github.com/eileenmcnaughton/nz.co.fuzion.omnipaymultiprocessor.git"
default[:civicrm][:extensions][:omnipay][:revision] = "3.19"

# Pay with Stripe
default[:civicrm][:extensions][:stripe][:name] = "stripe"
default[:civicrm][:extensions][:stripe][:repository] = "https://lab.civicrm.org/extensions/stripe.git"
default[:civicrm][:extensions][:stripe][:revision] = "6.9.3"
