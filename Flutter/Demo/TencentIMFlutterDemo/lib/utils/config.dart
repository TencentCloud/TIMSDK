class Config {
  static const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 0);
  static const String key = String.fromEnvironment('KEY', defaultValue: "");
  static const bool productEnv =
      bool.fromEnvironment('ISPRODUCT_ENV', defaultValue: false);
}
