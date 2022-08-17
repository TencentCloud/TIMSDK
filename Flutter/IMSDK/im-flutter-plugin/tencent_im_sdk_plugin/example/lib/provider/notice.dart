import 'package:flutter/cupertino.dart';

class Notice with ChangeNotifier {
  int _noticeCount = 0;
  int get noticeCount => _noticeCount;

  int addNoticeCount(int count) {
    _noticeCount += count;
    notifyListeners();
    return _noticeCount;
  }

  void removeNoticeCount() {
    _noticeCount = 0;
    notifyListeners();
  }
}
