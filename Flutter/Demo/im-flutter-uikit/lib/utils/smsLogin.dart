// 短信验证码登录，开发者用不到，可以去掉此部分

// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/utils/request.dart';

class SmsLogin {
  static Future<Map<String, dynamic>?> getGlsb() async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/base/v1/gslb",
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 验证防水墙验证
  // "phone"
  // "ticket"
  //  "randstr"
  static vervifyPicture({
    required String phone,
    required String ticket,
    required String randstr,
    required String appId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
        path: "/base/v1/auth_users/user_verify_by_picture",
        method: "post",
        data: <String, dynamic>{
          "phone": phone,
          "appId": appId,
          "ticket": ticket,
          "randstr": randstr,
          "apaasAppId": "1026227964",
        });
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 验证码登录
  // "sessionId"
  // "phone"
  static smsFirstLogin({
    required String phone,
    required String sessionId,
    required String code,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
        path: "/base/v1/auth_users/user_login_code",
        method: "post",
        data: <String, dynamic>{
          "sessionId": sessionId,
          "phone": phone,
          "code": code,
          "apaasAppId": "1026227964",
          "tag": "flutter_tuikit"
        });
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // token登录
  // "userId"
  // "token"
  static smsTokenLogin({
    required String userId,
    required String token,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
        path: "/base/v1/auth_users/user_login_token",
        method: "post",
        data: <String, dynamic>{
          "userId": userId,
          "token": token,
          "apaasAppId": "1026227964"
        });
    Map<String, dynamic> res = data.data!;
    return res;
  }

  static initLoginService() async {
    await Dio(BaseOptions(
      method: "get",
    )).request(
      IMDemoConfig.captchaUrl,
    );
  }

  // 修改用户信息
  static smsChangeUserInfo({
    required String userId,
    required String token,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
        path: "/base/v1/auth_users/user_update",
        method: "post",
        data: <String, dynamic>{
          "userId": userId,
          "token": token,
          "tag": "flutter_tuikit",
          "apaasAppId": "1026227964"
        });
    Map<String, dynamic> res = data.data!;
    return res;
  }
}
