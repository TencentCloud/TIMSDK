import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  static Future<bool> isAndroidEmulator() async {
    if (!kIsWeb && Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      final isPhysicalDevice = androidInfo.isPhysicalDevice ?? false;
      return !isPhysicalDevice;
    }
    return false;
  }
}
