import 'package:dio/dio.dart';
import 'package:discuss/config.dart';
import 'package:discuss/utils/const.dart';

Future<Response<Map<String, dynamic>>> appRequest({
  String? method = 'get',
  Map<String, dynamic>? params,
  required String path,
  dynamic data,
  String? baseUrl,
}) async {
  BaseOptions options = BaseOptions(
    baseUrl: baseUrl ?? IMDiscussConfig.smsLoginHttpBase,
    method: method,
    sendTimeout: 6000,
    queryParameters: params,
  );
  try {
    return await Dio(options).request<Map<String, dynamic>>(
      path,
      data: data,
      queryParameters: params,
    );
  } on DioError catch (e) {
    // Server error 服务端问题
    if (e.response != null) {
      return Response(data: {
        'errorCode': Const.SERVER_ERROR_CODE,
        'errorMessage': '服务器错误：${e.message}',
      }, requestOptions: e.requestOptions);
    } else {
      // Request error 请求时的问题
      return Response(data: {
        'errorCode': Const.REQUEST_ERROR_CODE,
        'errorMessage': '请求错误：${e.message}',
      }, requestOptions: e.requestOptions);
    }
  }
}
