import 'package:flutter/foundation.dart';

class DiscussData with ChangeNotifier {
  List<Map<String, dynamic>> _channelList = [];
  List<Map<String, dynamic>> get channelList => _channelList;
  int _currentSelectedChanel = 0;
  int get currentSelectedChanel => _currentSelectedChanel;

  List<Map<String, dynamic>> _discussList = [];
  List<Map<String, dynamic>> get discussList => _discussList;

  updateDiscussList(List<Map<String, dynamic>> list) {
    _discussList = list;
    notifyListeners();
  }

  List<Map<String, dynamic>> getDiscussListByCategrey(String catgrey) {
    return _discussList
        .where((element) => element['category'] == catgrey)
        .toList();
  }

  updateCurrentSelectedChanel(int current) {
    _currentSelectedChanel = current;
    notifyListeners();
  }

  updateChanelList(List<Map<String, dynamic>> list) {
    _channelList = list;
    notifyListeners();
  }

  Map<String, dynamic>? get currentChanelInfo {
    return _channelList.isNotEmpty
        ? _channelList[_currentSelectedChanel]
        : null;
  }
}
