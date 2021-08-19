import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('tencent_im_sdk_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      var a = Map<String, dynamic>();
      a['data'] = true;
      return a;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
