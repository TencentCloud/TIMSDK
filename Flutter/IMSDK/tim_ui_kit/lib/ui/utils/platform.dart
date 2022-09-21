import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  PlatformUtils._internal();
  static late bool _isAndroid;
  static late bool _isIos;
  static late bool _isWeb;
  static bool _isInstantiation = false;

  factory PlatformUtils() {
    if (!_isInstantiation) {
      _isAndroid = !kIsWeb && Platform.isAndroid;
      _isIos = !kIsWeb && Platform.isIOS;
      _isWeb = kIsWeb;
      _isInstantiation = true;
    }

    return _instance;
  }

  static late final PlatformUtils _instance = PlatformUtils._internal();

  get isAndroid {
    return _isAndroid;
  }

  get isWeb {
    return _isWeb;
  }

  get isIOS {
    return _isIos;
  }
}
