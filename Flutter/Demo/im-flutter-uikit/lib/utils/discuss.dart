// 频道 讨论区Api

import 'package:dio/dio.dart';
import './request.dart';

import '../src/config.dart';

class DisscussApi {
  static String baseUrl = IMDemoConfig.productEnv
      ? 'https://service-brnvps08-1256635546.gz.apigw.tencentcs.com/release/'
      : 'https://service-7x3j2zkw-1256635546.gz.apigw.tencentcs.com/release/';
  // static String baseUrl = 'http://127.0.0.1:3000/';
  // 获取讨论区列表
  static Future<Map<String, dynamic>> getDiscussList({
    int? offset = 0,
    int? limit = 10,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/getList",
      baseUrl: baseUrl,
      params: {
        "offset": offset,
        "limit": limit,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 判断群组是否是讨论区
  static Future<Map<String, dynamic>> isValidateDisscuss({
    required String imGroupId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/isValidateDisscuss",
      baseUrl: baseUrl,
      params: {
        "imGroupId": imGroupId,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 获取讨论区详情
  static Future<Map<String, dynamic>> getDisscussInfo({
    required String imGroupId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/getDisscussInfo",
      baseUrl: baseUrl,
      params: {
        "imGroupId": imGroupId,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 创建话题
  static Future<Map<String, dynamic>> addTopic({
    required String title,
    required String tags,
    required String creator,
    required String disscussImGroupId,
    required String aboutMessages,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/addTopic",
      baseUrl: baseUrl,
      method: "post",
      data: {
        "disscussImGroupId": disscussImGroupId,
        "title": title,
        "tags": tags,
        "creator": creator,
        "aboutMessages": aboutMessages,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 获取话题列表
  static Future<Map<String, dynamic>> getTopicList({
    required int type,
    String? userId = '',
    int? limit = 10,
    int? offset = 0,
    required String disscussImGroupId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/getTopicList",
      baseUrl: baseUrl,
      params: {
        "disscussImGroupId": disscussImGroupId,
        "type": type,
        "userId": userId,
        "limit": limit,
        "offset": offset,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

// 加入话题
  static Future<Map<String, dynamic>> joinTopic({
    required String userId,
    required String imGroupId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/joinTopic",
      baseUrl: baseUrl,
      method: 'post',
      data: {
        "imGroupId": imGroupId,
        "userId": userId,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 是否是管理员
  static Future<Map<String, dynamic>> isValidateAdimn({
    required String userId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/isValidateAdmin",
      baseUrl: baseUrl,
      params: {
        "userId": userId,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  // 全部管理区
  static Future<Map<String, dynamic>> allDiscussAndTopic() async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/allDiscussAndTopic",
      baseUrl: baseUrl,
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  static Future<Map<String, dynamic>> getTopicInfo({
    required String imGroupId,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/getTopicInfo",
      baseUrl: baseUrl,
      params: {
        "imGroupId": imGroupId,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  static Future<Map<String, dynamic>> updateTopicStatus({
    required String imGroupId,
    required String status,
  }) async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/updateTopicStatus",
      baseUrl: baseUrl,
      method: "post",
      data: {
        "imGroupId": imGroupId,
        "status": status,
      },
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }

  static Future<Map<String, dynamic>> getChannelList() async {
    Response<Map<String, dynamic>> data = await appRequest(
      path: "/disscuss/getChanelList",
      baseUrl: baseUrl,
      method: "get",
    );
    Map<String, dynamic> res = data.data!;
    return res;
  }
}
