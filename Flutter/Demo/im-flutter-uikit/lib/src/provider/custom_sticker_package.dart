import 'package:flutter/material.dart';
import 'package:tim_ui_kit_sticker_plugin/utils/tim_ui_kit_sticker_data.dart';

class CustomStickerPackageData extends ChangeNotifier {
  List<CustomStickerPackage> _customStickerPackageList = [];
  int _selectedIdx = 0;
  List<int> _emojiIndexList = [];
  List<CustomStickerPackage> get customStickerPackageList {
    return _customStickerPackageList;
  }

  int get selectedIdx {
    return _selectedIdx;
  }

  List<int> get emojiIndexList {
    return _emojiIndexList;
  }

  set selectedIdx(int idx) {
    _selectedIdx = idx;
    notifyListeners();
  }

  set customStickerPackageList(List<CustomStickerPackage> list) {
    _customStickerPackageList = list;
    list.asMap().keys.forEach((customStickerPackageIndex) {
      if (!_customStickerPackageList[customStickerPackageIndex]
          .isCustomSticker) {
        _emojiIndexList.add(customStickerPackageIndex);
      }
    });
    notifyListeners();
  }

  addStickerPackage(CustomStickerPackage sticker) {
    if (!sticker.isCustomSticker) {
      _emojiIndexList.add(_customStickerPackageList.length);
    }
    _customStickerPackageList.add(sticker);
    notifyListeners();
  }

  removeEmojiPackage(CustomStickerPackage sticker) {
    // TODO
  }

  clearStickerPackageList() {
    _customStickerPackageList = [];
    _selectedIdx = 0;
    _emojiIndexList = [];
  }
}
