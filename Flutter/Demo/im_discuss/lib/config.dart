class IMDiscussConfig {
  static const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 0);
  static const String key = String.fromEnvironment('KEY', defaultValue: "");
  static const bool productEnv =
      bool.fromEnvironment('ISPRODUCT_ENV', defaultValue: false);
  static const String smsLoginHttpBase =
      'https://demos.trtc.tencent-cloud.com/prod';
  static const String captchaUrl =
      'https://imgcache.qq.com/operation/dianshi/other/index.e7ef9e022229b9167136a9ed48572f258fe7d528.html';
  static const int loglevel = 3;
  static const String appName = "云通信·IM";
  static const pushConfig = <String, Map<String, double>>{
    "ios": {
      "dev": 30626,
      "prod": 30572,
    },
  };
  static const double appBarTitleFontSize = 14;
}
