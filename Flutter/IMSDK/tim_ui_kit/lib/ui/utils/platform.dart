import 'dart:io';

class PlatformUtils {
  PlatformUtils._internal();
  static late bool _isAndroid;
  static late bool _isIos;
  static bool _isInstantiation = false;

  factory PlatformUtils() {
    if (!_isInstantiation) {
      _isAndroid = Platform.isAndroid;
      _isIos = Platform.isIOS;
      _isInstantiation = true;
    }

    return _instance;
  }

  static late final PlatformUtils _instance = PlatformUtils._internal();

  get isAndroid {
    return _isAndroid;
  }

  get isIOS {
    return _isIos;
  }
}
