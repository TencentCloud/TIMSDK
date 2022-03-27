import '../i18n/i18n_utils.dart';

enum WebUrl { personalInfo, thirdPartyInfo }

class IMDemoConfig {
  static const int sdkappid = int.fromEnvironment('SDK_APPID', defaultValue: 0);
  static const String key = String.fromEnvironment('KEY', defaultValue: "");
  static const String appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: "0.0.1");
  static const String projectType =
      String.fromEnvironment('PROJECT_TYPE', defaultValue: "discord");
  static const bool productEnv =
      bool.fromEnvironment('ISPRODUCT_ENV', defaultValue: false);
  static const String smsLoginHttpBase =
      'https://demos.trtc.tencent-cloud.com/prod';
  // static const String captchaUrl =
  // 'https://imgcache.qq.com/operation/dianshi/other/captcha.11f3ef11e3657473779f28383735c6a680a87180.html';
  static const String captchaUrl =
      'https://imgcache.qq.com/operation/dianshi/other/captcha.b7104193bf789d667fbc2ed45d8bbd31434876ad.html';
  static const int loglevel = 3;
  static String appName = imt("云通信·IM");
  static const pushConfig = <String, Map<String, double>>{
    "ios": {
      "dev": 30626,
      "prod": 30572,
    },
  };
  // appBarTile无法做适配，必须要常量才可以
  static const double appBarTitleFontSize = 17;

  static const Map<WebUrl, String> webUrls = {
    WebUrl.personalInfo:
        "https://privacy.qq.com/document/preview/45ba982a1ce6493597a00f8c86b52a1e",
    WebUrl.thirdPartyInfo:
        "https://privacy.qq.com/document/preview/dea84ac4bb88454794928b77126e9246",
  };
}
