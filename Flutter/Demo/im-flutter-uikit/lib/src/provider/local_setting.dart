import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSetting with ChangeNotifier {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Record is show reading status in historical message list
  bool? _isShowReadingStatus;

  /// Record is show online status of other users
  bool? _isShowOnlineStatus;

  bool get isShowReadingStatus => _isShowReadingStatus ?? true;

  set isShowReadingStatus(bool value) {
    _isShowReadingStatus = value;
    notifyListeners();
    updateSettingsToLocal("isShowReadingStatus", value);
  }

  bool get isShowOnlineStatus => _isShowOnlineStatus ?? true;

  set isShowOnlineStatus(bool value) {
    _isShowOnlineStatus = value;
    notifyListeners();
    updateSettingsToLocal("isShowOnlineStatus", value);
  }

  loadSettingsFromLocal() async{
    SharedPreferences prefs = await _prefs;
    _isShowOnlineStatus = prefs.getBool("isShowOnlineStatus");
    _isShowReadingStatus = prefs.getBool("isShowReadingStatus");
    notifyListeners();
  }

  updateSettingsToLocal(String setting, bool value) async{
    SharedPreferences prefs = await _prefs;
    prefs.setBool(setting, value);
  }

  LocalSetting(){
    loadSettingsFromLocal();
  }
}