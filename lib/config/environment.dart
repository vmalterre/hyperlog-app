/// Environment types for the app
enum Environment {
  dev,
  prod,
}

/// Environment-specific configuration
class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableDebugLogging;

  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableDebugLogging,
  });

  /// Dev environment - local WSL2 API
  /// Update _wsl2Ip if WSL2 restarts: run `hostname -I | awk '{print $1}'` in WSL2
  static const dev = EnvironmentConfig._(
    environment: Environment.dev,
    apiBaseUrl: 'http://192.168.137.186:3001/api',
    appName: 'HyperLog DEV',
    enableDebugLogging: true,
  );

  /// Prod environment - production VPS with TLS
  static const prod = EnvironmentConfig._(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.hyperlog.aero/api',
    appName: 'HyperLog',
    enableDebugLogging: false,
  );

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;
}
