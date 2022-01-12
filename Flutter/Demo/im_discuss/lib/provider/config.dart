import 'package:flutter/foundation.dart';

class AppConfig with ChangeNotifier, DiagnosticableTreeMixin {
  late String _appid;
  get appid => _appid;
  updateAppId(String data) {
    _appid = data;
    notifyListeners();
  }
}
