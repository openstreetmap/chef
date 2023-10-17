default[:civicrm][:version] = "5.66.0"

# was used for SotM
# default[:civicrm][:extensions][:cividiscount][:name] = "org.civicrm.module.cividiscount"
# default[:civicrm][:extensions][:cividiscount][:repository] = "https://lab.civicrm.org/extensions/cividiscount.git"
# default[:civicrm][:extensions][:cividiscount][:revision] = "3.8.8"

# used to email people from civicrm
default[:civicrm][:extensions][:emailapi][:name] = "org.civicoop.emailapi"
default[:civicrm][:extensions][:emailapi][:repository] = "https://lab.civicrm.org/extensions/emailapi.git"
default[:civicrm][:extensions][:emailapi][:revision] = "2.11"

# fancy email templates - INSTALL MANUALLY, NOT FROM GIT
default[:civicrm][:extensions][:mosaico][:name] = "uk.co.vedaconsulting.mosaico"
default[:civicrm][:extensions][:mosaico][:zip] = "https://download.civicrm.org/extension/uk.co.vedaconsulting.mosaico/3.3.1697392242/uk.co.vedaconsulting.mosaico-3.3.1697392242.zip"

# validate that osm username exists, simple check
default[:civicrm][:extensions][:username][:name] = "org.openstreetmap.username"
default[:civicrm][:extensions][:username][:repository] = "https://github.com/grischard/org.openstreetmap.username.git"
default[:civicrm][:extensions][:username][:revision] = "ac86edbe29cf076cd956507ac6cec4bf6c5a137d"

# do not send report emails if daily report is empty (mwg)
default[:civicrm][:extensions][:donotsendreportemail][:name] = "org.civicrm.donotsendreportemail"
default[:civicrm][:extensions][:donotsendreportemail][:repository] = "https://github.com/pradpnayak/org.civicrm.donotsendreportemail.git"
default[:civicrm][:extensions][:donotsendreportemail][:revision] = "3b31c2e0c62183872c7ecd244395fb8dcfbd5dbb"

# make civicrm look nicer
default[:civicrm][:extensions][:theisland][:name] = "theisland"
default[:civicrm][:extensions][:theisland][:repository] = "https://lab.civicrm.org/extensions/theisland.git"
default[:civicrm][:extensions][:theisland][:revision] = "2.1.0"

# civiprospect
default[:civicrm][:extensions][:civiprospect][:name] = "uk.co.compucorp.civicrm.prospect"
default[:civicrm][:extensions][:civiprospect][:repository] = "https://github.com/compucorp/uk.co.compucorp.civicrm.prospect.git"
default[:civicrm][:extensions][:civiprospect][:revision] = "3.1.2"

# advanced fundraising reports
default[:civicrm][:extensions][:advancedfundraisingreports][:name] = "net.ourpowerbase.report.advancedfundraising"
default[:civicrm][:extensions][:advancedfundraisingreports][:repository] = "https://github.com/jmcclelland/net.ourpowerbase.report.advancedfundraising.git"
default[:civicrm][:extensions][:advancedfundraisingreports][:revision] = "3d5bd6cab70ba338bc85d42b4853dd4a6f8c9f9b"

# membership churn report
default[:civicrm][:extensions][:membershipchurn][:name] = "uk.co.vedaconsulting.membershipchurnchart"
default[:civicrm][:extensions][:membershipchurn][:repository] = "https://github.com/veda-consulting/uk.co.vedaconsulting.membershipchurnchart.git"
default[:civicrm][:extensions][:membershipchurn][:revision] = "v1.1"

# pivot reports for civiprospect
default[:civicrm][:extensions][:pivotreport][:name] = "uk.co.compucorp.civicrm.pivotreport"
default[:civicrm][:extensions][:pivotreport][:repository] = "https://github.com/compucorp/uk.co.compucorp.civicrm.pivotreport.git"
default[:civicrm][:extensions][:pivotreport][:revision] = "2.0.7"

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
default[:civicrm][:extensions][:stripe][:name] = "com.drastikbydesign.stripe"
default[:civicrm][:extensions][:stripe][:repository] = "https://lab.civicrm.org/extensions/stripe.git"
default[:civicrm][:extensions][:stripe][:revision] = "6.9.4"

# Stripe requires mjwshared
default[:civicrm][:extensions][:mjwshared][:name] = "com.mjwconsult.mjwshared"
default[:civicrm][:extensions][:mjwshared][:repository] = "https://lab.civicrm.org/extensions/mjwshared.git"
default[:civicrm][:extensions][:mjwshared][:revision] = "1.2.15"

# Stripe requires sweetalert
default[:civicrm][:extensions][:sweetalert][:name] = "org.civicrm.sweetalert"
default[:civicrm][:extensions][:sweetalert][:repository] = "https://lab.civicrm.org/extensions/sweetalert.git"
default[:civicrm][:extensions][:sweetalert][:revision] = "1.5"

# Stripe requires firewall
default[:civicrm][:extensions][:firewall][:name] = "org.civicrm.firewall"
default[:civicrm][:extensions][:firewall][:repository] = "https://lab.civicrm.org/extensions/firewall.git"
default[:civicrm][:extensions][:firewall][:revision] = "1.5.9"
