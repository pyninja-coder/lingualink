class Settings {
  final bool receiveNotifications;
  final String theme;
  final String name; // User's name
  final String languagePreference; // User's language preference

  Settings({
    required this.receiveNotifications,
    required this.theme,
    required this.name,
    required this.languagePreference,
  });
}
