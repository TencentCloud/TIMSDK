import 'package:flutter/foundation.dart';

class MultiSelect with ChangeNotifier, DiagnosticableTreeMixin {
  bool _isopen = false;
  bool get isopen => _isopen;
  Map<String, bool> _longPressbubbleShow = {};
  Map<String, List<String>> _selectIds = {};
  Map<String, List<String>> get selectedIds => _selectIds;
  upateIsOpen(bool flag) {
    _isopen = flag;
    notifyListeners();
  }

  updateLongPressbubbleShow(String msgId, bool show) {
    _longPressbubbleShow = {};
    _longPressbubbleShow[msgId] = show;
    notifyListeners();
  }

  bool getLongPressBubbleShow(String msgId) {
    return _longPressbubbleShow[msgId] ?? false;
  }

  resetLongPressBubbleShow() {
    _longPressbubbleShow = {};
    notifyListeners();
  }

  updateSeletor(String key, String value) {
    if (_selectIds[key] == null) {
      _selectIds[key] = List.empty(growable: true);
    }
    if (_selectIds[key]!.contains(value)) {
      _selectIds[key]!.remove(value);
    } else {
      _selectIds[key]!.add(value);
    }
    notifyListeners();
  }

  exit() {
    _isopen = false;
    _selectIds = {};
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<bool>('isopen', isopen));
    properties.add(
      ObjectFlagProperty<Map<String, List<String>>>('selectedIds', _selectIds),
    );
  }
}
