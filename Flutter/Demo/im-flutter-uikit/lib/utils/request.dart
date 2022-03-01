import 'package:dio/dio.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/utils/constant.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

Future<Response<Map<String, dynamic>>> appRequest({
  String? method = 'get',
  Map<String, dynamic>? params,
  required String path,
  dynamic data,
  String? baseUrl,
}) async {
  BaseOptions options = BaseOptions(
    baseUrl: baseUrl ?? IMDemoConfig.smsLoginHttpBase,
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
      final errorMessage = e.message;
      return Response(data: {
        'errorCode': Const.SERVER_ERROR_CODE,
        'errorMessage': imt_para("服务器错误：{{errorMessage}}", "服务器错误：${errorMessage}")(errorMessage: errorMessage),
      }, requestOptions: e.requestOptions);
    } else {
      // Request error 请求时的问题
      final requestErrorMessage = e.message;
      return Response(data: {
        'errorCode': Const.REQUEST_ERROR_CODE,
        'errorMessage': imt_para("请求错误：{{requestErrorMessage}}", "请求错误：${requestErrorMessage}")(requestErrorMessage: requestErrorMessage),
      }, requestOptions: e.requestOptions);
    }
  }
}
