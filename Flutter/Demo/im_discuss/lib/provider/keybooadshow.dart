import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class KeyBoradModel with ChangeNotifier, DiagnosticableTreeMixin {
  bool _show = true;
  bool _recordBackStatus = true;
  bool _keyBoardshowStatus = false;
  bool get show => _show;
  bool get recordBackStatus => _recordBackStatus;
  bool get keyBoardshowStatus => _keyBoardshowStatus;
  String get bottomContainer => _bottomContainer;
  late TextEditingController _inputController;
  late Function _submitTextMessage;
  late ScrollController _scrollController;
  String _bottomContainer = "empty";

  V2TimMessage? _replyMessage;
  V2TimMessage? get replyMessage => _replyMessage;
  TextEditingController get inputController => _inputController;
  ScrollController get scrollController => _scrollController;

  static late FocusNode _inputFieldNode;
  //输入款底部区域
  setBottomConToKeyBoard({context}) {
    _bottomContainer = "keyboardContainer";
    notifyListeners();
  }

  setBottomConToAdvMsg() {
    _bottomContainer = "advanceMsgContainer";
    notifyListeners();
  }

  setBottomConToFace() {
    _bottomContainer = "faceContainner";
    notifyListeners();
  }

  setBottomConToEmpty() {
    _bottomContainer = "empty";
    notifyListeners();
  }

  setReplyMessage(V2TimMessage message) {
    _replyMessage = message;
    notifyListeners();
  }

  cleanReplyMessage() {
    _replyMessage = null;
    notifyListeners();
  }

  updateRecordBackStatus(bool status) {
    _recordBackStatus = status;
    notifyListeners();
  }

  // 是否切换并展示键盘
  showkeyborad() {
    _show = true;
    notifyListeners();
  }

  hidekeyborad() {
    _show = false;
    notifyListeners();
  }

  //此status是为了控制输入框的显示
  setStatus(bool status) {
    _show = status;
    notifyListeners();
  }

  setFocusNode(FocusNode node) {
    _inputFieldNode = node;
    _inputFieldNode.addListener(() {
      _keyBoardshowStatus = _inputFieldNode.hasFocus;
      notifyListeners();
    });
  }

  // 打开软键盘
  keyBoardFocus() {
    _keyBoardshowStatus = true;
    _inputFieldNode.requestFocus();
    notifyListeners();
  }

  keyBoardUnfocus() {
    _keyBoardshowStatus = false;
    _inputFieldNode.unfocus();
    notifyListeners();
  }

  setScrollController(ScrollController controller) {
    _scrollController = controller;
    notifyListeners();
  }

  // 跳到聊天栏的最底部
  jumpToScrollControllerBottom() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 400), curve: Curves.ease);
    notifyListeners();
  }

  // 停止滑动
  stopScroll() {
    _scrollController.jumpTo(_scrollController.offset);
  }

  setKeyBoardshowStatus(bool status) {
    _keyBoardshowStatus = status;
    notifyListeners();
  }

  setInputController(TextEditingController controller) {
    _inputController = controller;
    notifyListeners();
  }

  setSubmitTextMessage(Function cb) {
    _submitTextMessage = cb;
  }

  triggerSubmitTextMessage(String text, V2TimMessage? replyMessage) {
    _submitTextMessage(text, _replyMessage);
  }

  pushTextToInputController(String addText) {
    String oldText = _inputController.text;
    _inputController.text = "$oldText$addText";

    notifyListeners();
  }

  disposeInputController() {
    if (_inputController != null) {
      _inputController.dispose();
    }

    notifyListeners();
  }
}
