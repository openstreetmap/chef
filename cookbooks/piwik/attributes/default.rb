default[:piwik][:version] = "4.10.1"
default[:piwik][:plugins] = %w[
  Actions Annotations API BulkTracking Contents CoreAdminHome CoreConsole
  CoreHome CorePluginsAdmin CoreUpdater CoreVisualizations CoreVue
  CustomJsTracker Dashboard DBStats DevicePlugins DevicesDetection Diagnostics
  Ecommerce Events Feedback GeoIp2 Goals Heartbeat ImageGraph Insights
  Installation Intl IntranetMeasurable LanguagesManager Live Login Marketplace
  MobileAppMeasurable MobileMessaging Monolog Morpheus MultiSites Overlay
  PagePerformance PrivacyManager ProfessionalServices Proxy Referrers Resolution
  RssWidget ScheduledReports SegmentEditor SEO SitesManager Tour Transitions
  TwoFactorAuth UserCountry UserCountryMap UserId UserLanguage UsersManager
  VisitFrequency VisitorInterest VisitsSummary VisitTime WebsiteMeasurable
  Widgetize
]

default[:mysql][:settings][:mysqld][:secure_file_priv] = "/opt/piwik-#{node[:piwik][:version]}/piwik/tmp/assets"
