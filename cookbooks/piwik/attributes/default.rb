default[:piwik][:version] = "3.2.1"
default[:piwik][:plugins] = %w[
  Actions API BulkTracking Contents CoreAdminHome CoreConsole CoreHome
  CorePluginsAdmin CoreUpdater CoreVisualizations CustomVariables
  Dashboard DevicesDetection DevicePlugins DoNotTrack Events Feedback Goals
  Heartbeat ImageGraph Installation LanguagesManager Live Login Morpheus
  MultiSites Overlay PrivacyManager Provider Proxy Referrers Resolution
  SegmentEditor SEO SitesManager Transitions UserCountry UserCountryMap
  UserLanguage UsersManager Widgetize VisitFrequency VisitorInterest
  VisitsSummary VisitTime
]
