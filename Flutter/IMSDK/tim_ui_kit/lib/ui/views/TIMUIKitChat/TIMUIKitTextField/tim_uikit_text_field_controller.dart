import 'package:flutter/material.dart';

enum ActionType { hideAllPanel, longPressToAt }

class TIMUIKitInputTextFieldController extends ChangeNotifier {
  TextEditingController? textEditingController = TextEditingController();
  ActionType? actionType;
  String? atUserName;
  String? atUserID;

  TIMUIKitInputTextFieldController([TextEditingController? controller]) {
    if (controller != null) {
      textEditingController = controller;
    }
  }

  /// text field unfocus and hide all panel
  hideAllPanel() {
    actionType = ActionType.hideAllPanel;
    notifyListeners();
  }

  longPressToAt(String? userName, String? userID) {
    actionType = ActionType.longPressToAt;
    atUserName = userName;
    atUserID = userID;
    notifyListeners();
  }
}
