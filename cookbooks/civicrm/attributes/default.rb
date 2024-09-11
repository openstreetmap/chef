# See https://docs.civicrm.org/installation/en/latest/general/requirements/ for required php versions
default[:civicrm][:version] = "5.74.4"

# was used for SotM
# default[:civicrm][:extensions][:cividiscount][:name] = "org.civicrm.module.cividiscount"
# default[:civicrm][:extensions][:cividiscount][:repository] = "https://lab.civicrm.org/extensions/cividiscount.git"
# default[:civicrm][:extensions][:cividiscount][:revision] = "3.8.8"

# used to email people from civicrm
default[:civicrm][:extensions][:emailapi][:name] = "org.civicoop.emailapi"
default[:civicrm][:extensions][:emailapi][:repository] = "https://lab.civicrm.org/extensions/emailapi.git"
default[:civicrm][:extensions][:emailapi][:revision] = "2.14"

# fancy email templates - INSTALL MANUALLY, NOT FROM GIT
default[:civicrm][:extensions][:mosaico][:name] = "uk.co.vedaconsulting.mosaico"
default[:civicrm][:extensions][:mosaico][:zip] = "https://download.civicrm.org/extension/uk.co.vedaconsulting.mosaico/3.5.1709296836/uk.co.vedaconsulting.mosaico-3.5.1709296836.zip"

# validate that osm username exists, simple check
default[:civicrm][:extensions][:username][:name] = "org.openstreetmap.username"
default[:civicrm][:extensions][:username][:repository] = "https://github.com/grischard/org.openstreetmap.username.git"
default[:civicrm][:extensions][:username][:revision] = "9d67583bd3e0342a9770cde48f23586f707012ee"

# do not send report emails if daily report is empty (mwg)
default[:civicrm][:extensions][:donotsendreportemail][:name] = "org.civicrm.donotsendreportemail"
default[:civicrm][:extensions][:donotsendreportemail][:repository] = "https://github.com/pradpnayak/org.civicrm.donotsendreportemail.git"
default[:civicrm][:extensions][:donotsendreportemail][:revision] = "1.0"

# make civicrm look nicer
default[:civicrm][:extensions][:theisland][:name] = "theisland"
default[:civicrm][:extensions][:theisland][:repository] = "https://lab.civicrm.org/extensions/theisland.git"
default[:civicrm][:extensions][:theisland][:revision] = "2.3.3"

# civiprospect
default[:civicrm][:extensions][:civiprospect][:name] = "uk.co.compucorp.civicrm.prospect"
default[:civicrm][:extensions][:civiprospect][:repository] = "https://github.com/compucorp/uk.co.compucorp.civicrm.prospect.git"
default[:civicrm][:extensions][:civiprospect][:revision] = "3.1.2"

# advanced fundraising reports
# default[:civicrm][:extensions][:advancedfundraisingreports][:name] = "net.ourpowerbase.report.advancedfundraising"
# default[:civicrm][:extensions][:advancedfundraisingreports][:repository] = "https://github.com/jmcclelland/net.ourpowerbase.report.advancedfundraising.git"
# default[:civicrm][:extensions][:advancedfundraisingreports][:revision] = "3d5bd6cab70ba338bc85d42b4853dd4a6f8c9f9b"

# membership churn report
default[:civicrm][:extensions][:membershipchurn][:name] = "uk.co.vedaconsulting.membershipchurnchart"
default[:civicrm][:extensions][:membershipchurn][:repository] = "https://github.com/veda-consulting/uk.co.vedaconsulting.membershipchurnchart.git"
default[:civicrm][:extensions][:membershipchurn][:revision] = "v1.1"

# pivot reports for civiprospect
default[:civicrm][:extensions][:pivotreport][:name] = "uk.co.compucorp.civicrm.pivotreport"
# apply patch, pivot reports is currently broken. See https://github.com/compucorp/uk.co.compucorp.civicrm.pivotreport/pull/142
default[:civicrm][:extensions][:pivotreport][:repository] = "https://github.com/compucorp/uk.co.compucorp.civicrm.pivotreport.git"
default[:civicrm][:extensions][:pivotreport][:revision] = "9a96eee9e0541568440af54e9408d5f462ae00df"

# extra rules for membership renewal
default[:civicrm][:extensions][:membershipextra][:name] = "com.skvare.membershipextra"
default[:civicrm][:extensions][:membershipextra][:repository] = "https://github.com/Skvare/com.skvare.membershipextra.git"
default[:civicrm][:extensions][:membershipextra][:revision] = "847fa370639d4ace4e33d6c055d9866e3d2e5afd"

# Verify active contributor status
default[:civicrm][:extensions][:osmfverifycontributor][:name] = "osmf-verify-contributor"
default[:civicrm][:extensions][:osmfverifycontributor][:repository] = "https://github.com/openstreetmap/osmf-verify-contributor.git"
default[:civicrm][:extensions][:osmfverifycontributor][:revision] = "73e4d5cf77623cb9a6217f0b0166386f96330b6f"

# Pay with Mollie
default[:civicrm][:extensions][:omnipay][:name] = "nz.co.fuzion.omnipaymultiprocessor"
default[:civicrm][:extensions][:omnipay][:repository] = "https://github.com/eileenmcnaughton/nz.co.fuzion.omnipaymultiprocessor.git"
default[:civicrm][:extensions][:omnipay][:revision] = "3.23"

# Pay with Stripe
default[:civicrm][:extensions][:stripe][:name] = "com.drastikbydesign.stripe"
default[:civicrm][:extensions][:stripe][:repository] = "https://lab.civicrm.org/extensions/stripe.git"
default[:civicrm][:extensions][:stripe][:revision] = "6.10.2"

# Stripe requires mjwshared ("payment shared")
default[:civicrm][:extensions][:mjwshared][:name] = "com.mjwconsult.mjwshared"
default[:civicrm][:extensions][:mjwshared][:repository] = "https://lab.civicrm.org/extensions/mjwshared.git"
default[:civicrm][:extensions][:mjwshared][:revision] = "1.2.22"

# Stripe requires sweetalert
default[:civicrm][:extensions][:sweetalert][:name] = "org.civicrm.sweetalert"
default[:civicrm][:extensions][:sweetalert][:repository] = "https://lab.civicrm.org/extensions/sweetalert.git"
default[:civicrm][:extensions][:sweetalert][:revision] = "1.6"

# Stripe requires firewall
default[:civicrm][:extensions][:firewall][:name] = "org.civicrm.firewall"
default[:civicrm][:extensions][:firewall][:repository] = "https://lab.civicrm.org/extensions/firewall.git"
default[:civicrm][:extensions][:firewall][:revision] = "1.5.10"

# qfsessionwarning Alerts the user about expired session cookies,
# for example if a user walks away from a contribution page and comes back later
# Also reduces messages in the log.
default[:civicrm][:extensions][:qfsessionwarning][:name] = "org.civicrm.qfsessionwarning"
default[:civicrm][:extensions][:qfsessionwarning][:repository] = "https://lab.civicrm.org/extensions/qfsessionwarning.git"
default[:civicrm][:extensions][:qfsessionwarning][:revision] = "1.3"

# The contribution forms like to use a geocoder. Use the CiviCRM geocoder which uses nominatim
default[:civicrm][:extensions][:geocoder][:name] = "org.wikimedia.geocoder"
default[:civicrm][:extensions][:geocoder][:repository] = "https://github.com/eileenmcnaughton/org.wikimedia.geocoder.git"
default[:civicrm][:extensions][:geocoder][:revision] = "1.12"
