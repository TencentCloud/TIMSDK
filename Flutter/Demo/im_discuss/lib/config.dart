class IMDiscussConfig {
  static const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 0);
  static const String key = String.fromEnvironment('KEY', defaultValue: "");
  static const bool productEnv =
      bool.fromEnvironment('ISPRODUCT_ENV', defaultValue: false);
  static const String smsLoginHttpBase =
      'https://demos.trtc.tencent-cloud.com/prod';
  static const String captchaUrl =
      'https://imgcache.qq.com/operation/dianshi/other/captcha.11f3ef11e3657473779f28383735c6a680a87180.html';
  static const int loglevel = 3;
  static const String appName = "云通信·IM";
  static const pushConfig = <String, Map<String, double>>{
    "ios": {
      "dev": 30626,
      "prod": 30572,
    },
  };
  // appBarTile无法做适配，必须要常量才可以
  static const double appBarTitleFontSize = 14;
}
