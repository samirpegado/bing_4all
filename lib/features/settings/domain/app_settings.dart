enum ThemePreference { system, light, dark }

enum ImageQuality { uhd, hd1080 }

class AppSettings {
  const AppSettings({
    this.launchAtStartup = false,
    this.autoUpdate = true,
    this.updateHour = 8,
    this.updateMinute = 0,
    this.market = '',
    this.applyToAllMonitors = true,
    this.preferredQuality = ImageQuality.uhd,
    this.downloadDirectory = '',
    this.cacheLimitMb = 500,
    this.theme = ThemePreference.system,
    this.notifications = true,
    this.restorePreviousOnExit = false,
  });

  final bool launchAtStartup;
  final bool autoUpdate;
  final int updateHour;
  final int updateMinute;
  final String market;
  final bool applyToAllMonitors;
  final ImageQuality preferredQuality;
  final String downloadDirectory;
  final int cacheLimitMb;
  final ThemePreference theme;
  final bool notifications;
  final bool restorePreviousOnExit;

  AppSettings copyWith({
    bool? launchAtStartup,
    bool? autoUpdate,
    int? updateHour,
    int? updateMinute,
    String? market,
    bool? applyToAllMonitors,
    ImageQuality? preferredQuality,
    String? downloadDirectory,
    int? cacheLimitMb,
    ThemePreference? theme,
    bool? notifications,
    bool? restorePreviousOnExit,
  }) {
    return AppSettings(
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      updateHour: updateHour ?? this.updateHour,
      updateMinute: updateMinute ?? this.updateMinute,
      market: market ?? this.market,
      applyToAllMonitors: applyToAllMonitors ?? this.applyToAllMonitors,
      preferredQuality: preferredQuality ?? this.preferredQuality,
      downloadDirectory: downloadDirectory ?? this.downloadDirectory,
      cacheLimitMb: cacheLimitMb ?? this.cacheLimitMb,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      restorePreviousOnExit:
          restorePreviousOnExit ?? this.restorePreviousOnExit,
    );
  }

  Map<String, dynamic> toJson() => {
        'launchAtStartup': launchAtStartup,
        'autoUpdate': autoUpdate,
        'updateHour': updateHour,
        'updateMinute': updateMinute,
        'market': market,
        'applyToAllMonitors': applyToAllMonitors,
        'preferredQuality': preferredQuality.name,
        'downloadDirectory': downloadDirectory,
        'cacheLimitMb': cacheLimitMb,
        'theme': theme.name,
        'notifications': notifications,
        'restorePreviousOnExit': restorePreviousOnExit,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      launchAtStartup: json['launchAtStartup'] as bool? ?? false,
      autoUpdate: json['autoUpdate'] as bool? ?? true,
      updateHour: json['updateHour'] as int? ?? 8,
      updateMinute: json['updateMinute'] as int? ?? 0,
      market: json['market'] as String? ?? '',
      applyToAllMonitors: json['applyToAllMonitors'] as bool? ?? true,
      preferredQuality: ImageQuality.values.firstWhere(
        (e) => e.name == json['preferredQuality'],
        orElse: () => ImageQuality.uhd,
      ),
      downloadDirectory: json['downloadDirectory'] as String? ?? '',
      cacheLimitMb: json['cacheLimitMb'] as int? ?? 500,
      theme: ThemePreference.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => ThemePreference.system,
      ),
      notifications: json['notifications'] as bool? ?? true,
      restorePreviousOnExit: json['restorePreviousOnExit'] as bool? ?? false,
    );
  }
}
