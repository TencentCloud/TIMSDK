import 'package:flutter/foundation.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class DiscussData with ChangeNotifier {
  List<Map<String, dynamic>> _channelList = [];
  final List<V2TimConversation> _conversationList = List.empty(growable: true);
  List<V2TimConversation> get conversationList => _conversationList;
  List<Map<String, dynamic>> get channelList => _channelList;
  int _currentSelectedChannel = 0;
  int get currentSelectedChannel => _currentSelectedChannel;

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

  updateCurrentSelectedChannel(int current) {
    _currentSelectedChannel = current;
    notifyListeners();
  }

  updateChannelList(List<Map<String, dynamic>> list) {
    _channelList = list;
    notifyListeners();
  }

  Map<String, dynamic>? get currentChannelInfo {
    return _channelList.isNotEmpty
        ? _channelList[_currentSelectedChannel]
        : null;
  }

  conversationItemChange(List<V2TimConversation> list) {
    for (int element = 0; element < list.length; element++) {
      int index = _conversationList.indexWhere(
          (item) => item.conversationID == list[element].conversationID);
      if (index > -1) {
        _conversationList.setAll(index, [list[element]]);
      } else {
        _conversationList.add(list[element]);
      }
    }
    sort();
    notifyListeners();
  }

  addNewConversation(List<V2TimConversation?> list) {
    _conversationList.addAll(List.from(list));
    sort();
    notifyListeners();
  }

  sort() {
    _conversationList.sort((a, b) => b.orderkey!.compareTo(a.orderkey!));
  }
}
