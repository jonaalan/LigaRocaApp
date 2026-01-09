enum EnvironmentType {
  dev,
  prod,
}

class AppEnvironment {
  final EnvironmentType type;
  final String appName;
  final String? bannerMessage;

  AppEnvironment({
    required this.type,
    required this.appName,
    this.bannerMessage,
  });

  bool get isDev => type == EnvironmentType.dev;
  bool get isProd => type == EnvironmentType.prod;
}
