import 'package:js/js.dart';

// 需要传递object时可以直接使用这种形式创建 对应博客：https://stackoverflow.com/questions/33394867/passing-dart-objects-to-js-functions-in-js-interop
@anonymous
@JS()
class TimParams {
  // ignore: non_constant_identifier_names
  external int get SDKAppID;
  // ignore: non_constant_identifier_names
  external set SDKAppID(int value);
}
