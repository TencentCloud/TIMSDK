import 'package:js/js.dart';

// 需要传递object时可以直接使用这种形式创建 对应博客：https://stackoverflow.com/questions/33394867/passing-dart-objects-to-js-functions-in-js-interop
@anonymous
@JS()
class LoginParams {
  external String get userID;
  external set userID(String value);

  external String get userSig;
  external set userSig(String value);
}
