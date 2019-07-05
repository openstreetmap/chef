default[:piwik][:version] = "3.10.0"
default[:piwik][:plugins] = %w[
  Actions Annotations API BulkTracking Contents CoreAdminHome CoreConsole
  CoreHome CorePluginsAdmin CoreUpdater CoreVisualizations CustomPiwikJs
  CustomVariables Dashboard DevicePlugins DevicesDetection Diagnostics Ecommerce
  Events Feedback GeoIp2 Goals Heartbeat ImageGraph Insights Installation Intl
  LanguagesManager Live Login Marketplace MobileMessaging Monolog Morpheus
  MultiSites Overlay PrivacyManager ProfessionalServices Provider Proxy
  Referrers Resolution RssWidget ScheduledReports SegmentEditor SEO SitesManager
  Transitions UserCountry UserCountryMap UserId UserLanguage UsersManager
  VisitFrequency VisitorInterest VisitsSummary VisitTime WebsiteMeasurable
  Widgetize
]
