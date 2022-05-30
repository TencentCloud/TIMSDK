import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils {
  static Future<bool> isAndroidEmulator() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      final isPhysicalDevice = androidInfo.isPhysicalDevice ?? false;
      return !isPhysicalDevice;
    }
    return false;
  }
}
