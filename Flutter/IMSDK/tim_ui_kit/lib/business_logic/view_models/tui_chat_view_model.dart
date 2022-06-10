// ignore_for_file: avoid_print, unnecessary_getters_setters, unnecessary_import, unused_local_variable

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tencent_im_sdk_plugin/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_message_read_member_list.dart';

enum ConvType { group, c2c }

enum HistoryMessagePosition { bottom, inTwoScreen, awayTwoScreen }

class TUIChatViewModel extends ChangeNotifier {
  final MessageService _messageService = serviceLocator<MessageService>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final Map<String, List<V2TimMessage>?> _messageListMap = {};
  final Map<String, V2TimMessageReceipt> _messageReadReceiptMap = {};
  final Map<String, int> _messageListProgressMap = {};

  bool _isDownloading = false;
  int _totalUnreadCount = 0;
  bool _isMultiSelect = false;
  String _currentSelectedConv = "";
  int? _currentSelectedConvType;
  bool _haveMoreData = true;
  String _currentSelectedMsgId = "";
  String _editRevokedMsg = "";
  GroupReceptAllowType? _groupType;
  final List<V2TimMessage> _multiSelectedMessageList = [];
  V2TimMessage? _repliedMessage;
  String localKeyPrefix = "TUIKit_conversation_stored_";
  String localMsgIDListKey = "TUIKit_conversation_list";
  String _jumpMsgID = "";
  V2TimAdvancedMsgListener? adVancesMsgListener;
  HistoryMessagePosition _listPosition = HistoryMessagePosition.bottom;
  int _unreadCountForConversation = 0;
  List<V2TimMessage>? _tempMessageList = [];
  TIMUIKitChatConfig chatConfig = const TIMUIKitChatConfig();
  ValueChanged<String>? _setInputField;
  List<V2TimGroupApplication>? _groupApplicationList;

  TUIChatViewModel() {
    removeAdvanceListener();
    initAdvanceListener();
    initMessageMapFromLocal();
  }

  bool get isDownloading => _isDownloading;

  Map<String, int> get messageListProgressMap {
    return _messageListProgressMap;
  }

  Map<String, List<V2TimMessage>?> get messageListMap {
    return _messageListMap;
  }

  bool get haveMoreData {
    return _haveMoreData;
  }

  String get jumpMsgID {
    return _jumpMsgID;
  }

  bool get isMultiSelect {
    return _isMultiSelect;
  }

  int get totalUnReadCount {
    return _totalUnreadCount;
  }

  String get currentSelectedMsgId {
    return _currentSelectedMsgId;
  }

  int? get currentSelectedConvType {
    return _currentSelectedConvType;
  }

  String get editRevokedMsg {
    return _editRevokedMsg;
  }

  String get currentSelectedConv {
    return _currentSelectedConv;
  }

  V2TimMessage? get repliedMessage {
    return _repliedMessage;
  }

  HistoryMessagePosition get listPosition => _listPosition;

  int get unreadCountForConversation => _unreadCountForConversation;

  ValueChanged<String>? get setInputField => _setInputField;

  List<V2TimGroupApplication> get groupApplicationList =>
      _groupApplicationList ?? [];

  set groupApplicationList(List<V2TimGroupApplication> value) {
    _groupApplicationList = value;
  }

  set setInputField(ValueChanged<String>? value) {
    _setInputField = value;
  }

  set unreadCountForConversation(int value) {
    _unreadCountForConversation = value;
  }

  set listPosition(HistoryMessagePosition value) {
    _listPosition = value;
    Future.delayed(const Duration(milliseconds: 1), () {
      notifyListeners();
    });
  }

  set currentSelectedMsgId(String msgID) {
    _currentSelectedMsgId = msgID;
    notifyListeners();
  }

  set totalUnReadCount(int newValue) {
    _totalUnreadCount = newValue;
    notifyListeners();
  }

  set editRevokedMsg(String msg) {
    _editRevokedMsg = msg;
    notifyListeners();
  }

  set jumpMsgID(String msgID) {
    _jumpMsgID = msgID;
    Future.delayed(const Duration(milliseconds: 1), () {
      notifyListeners();
    });
  }

  List<V2TimMessage> get multiSelectedMessageList {
    return _multiSelectedMessageList;
  }

  setChatConfig(TIMUIKitChatConfig config) {
    chatConfig = config;
  }

  initMessageMapFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localMsgIDList = prefs.getStringList(localMsgIDListKey);

    if (localMsgIDList != null) {
      for (String convID in localMsgIDList) {
        final List<String>? localMsgJson =
            prefs.getStringList("$localKeyPrefix$convID");
        if (localMsgJson != null) {
          List<V2TimMessage> localMsg = localMsgJson
              .map((item) => V2TimMessage.fromJson(jsonDecode(item)))
              .toList();
          _messageListMap[convID] = localMsg;
        }
      }
      notifyListeners();
    }
  }

  int getMessageProgress(String? msgID) {
    return _messageListProgressMap[msgID] ?? 0;
  }

  setMessageProgress(String msgID, int progress) {
    _messageListProgressMap[msgID] = progress;
    if (progress > 0 && progress < 100) {
      _isDownloading = true;
    } else {
      _isDownloading = false;
    }
    notifyListeners();
  }

  List<V2TimMessage>? getMessageListByConvId(String? convID) {
    final list = _messageListMap[convID]?.reversed.toList() ?? [];
    List<V2TimMessage> listWithTimestamp = [];
    for (var item in list) {
      {
        if (listWithTimestamp.isEmpty ||
            item.timestamp! -
                    listWithTimestamp[listWithTimestamp.length - 1].timestamp! >
                300) {
          listWithTimestamp.add(V2TimMessage(
            userID: '',
            isSelf: false,
            elemType: 11,
            msgID: '${item.timestamp}',
            timestamp: item.timestamp,
          ));
        }
        listWithTimestamp.add(item);
      }
    }
    return listWithTimestamp.reversed.toList();
    // return list;
  }

  void initForEachConversation(ValueChanged<String> onChangeInputField) async {
    _jumpMsgID = "";
    listPosition = HistoryMessagePosition.bottom;
    _tempMessageList = [];
    unreadCountForConversation = 0;
    setInputField = onChangeInputField;
    if (_groupApplicationList == null) {
      refreshGroupApplicationList();
    }
  }

  void refreshGroupApplicationList() async {
    final res = await _groupServices.getGroupApplicationList();
    _groupApplicationList = res.data?.groupApplicationList?.map((item) {
          final V2TimGroupApplication applicationItem = item!;
          return applicationItem;
        }).toList() ??
        [];
    notifyListeners();
  }

  void loadDataFromController(
      {String? receiverID, String? groupID, ConvType? convType}) {
    if (convType != null) {
      final convID = convType == ConvType.c2c ? receiverID : groupID;
      if (convID != null && convID.isNotEmpty) {
        loadData(
          count: HistoryMessageDartConstant.getCount, //20
          userID: convType == ConvType.c2c ? convID : null,
          groupID: convType == ConvType.group ? convID : null,
        );
      } else {
        print("ID is empty");
        return;
      }
    } else {
      loadData(
        count: HistoryMessageDartConstant.getCount, //20
        userID: _currentSelectedConvType == 1 ? _currentSelectedConv : null,
        groupID: _currentSelectedConvType == 2 ? _currentSelectedConv : null,
      );
    }
  }

  Future<bool> loadData({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    _currentSelectedConvType = userID != null ? 1 : 2;
    _haveMoreData = true;
    final convID = userID ?? groupID;
    final currentHistoryMsgList = _messageListMap[convID];
    final bool ifEmptyHistory =
        (currentHistoryMsgList == null || currentHistoryMsgList.isEmpty);

    final response = await _messageService.getHistoryMessageList(
        count: count,
        getType: getType,
        userID: userID,
        groupID: groupID,
        lastMsgID: lastMsgID,
        lastMsgSeq: lastMsgSeq);
    if (lastMsgID != null && currentHistoryMsgList != null) {
      _messageListMap[convID!] = [
        ...currentHistoryMsgList,
        ...response
      ]; // 拼接拉取更多历史
    } else {
      _messageListMap[convID!] = response; // 首屏默认历史消息
      // put the last 20 messages to local
      storeMsgToLocal(response, convID, ifEmptyHistory);
    }
    if (response.isEmpty || response.length < 20) {
      _haveMoreData = false;
    }
    _currentSelectedConv = convID;
    _currentSelectedConvType = userID != null ? 1 : 2;
    notifyListeners();
    if (chatConfig.isShowGroupReadingStatus &&
        _currentSelectedConvType == 2 &&
        response.isNotEmpty) {
      _getMsgReadReceipt(response);
      _setMsgReadReceipt(response);
    }
    if (_groupType == null &&
        chatConfig.isShowGroupReadingStatus &&
        _currentSelectedConvType == 2 &&
        groupID != null) {
      _getGroupInfo(groupID);
    }
    return _haveMoreData;
  }

  _getGroupInfo(String groupID) async {
    final res = await _groupServices.getGroupsInfo(groupIDList: [groupID]);
    if (res != null) {
      final groupRes = res.first;
      if (groupRes.resultCode == 0) {
        const groupTypeMap = {
          "Meeting": GroupReceptAllowType.meeting,
          "Public": GroupReceptAllowType.public,
          "Work": GroupReceptAllowType.work
        };

        _groupType = groupTypeMap[groupRes.groupInfo?.groupType];
      }
    }
  }

  void storeMsgToLocal(List<V2TimMessage>? msgList, String convID,
      [bool? addToIDList]) async {
    final prefs = await SharedPreferences.getInstance();

    if (addToIDList == true) {
      final List<String>? localMsgIDList =
          prefs.getStringList(localMsgIDListKey);
      if (localMsgIDList == null) {
        await prefs.setStringList(localMsgIDListKey, [convID]);
      } else if (!localMsgIDList.contains(convID)) {
        await prefs
            .setStringList(localMsgIDListKey, [...localMsgIDList, convID]);
      }
    }

    late List<String> storedMsgJsonList;
    if (msgList != null && msgList.isNotEmpty) {
      final storedMsg = msgList.getRange(0, min(20, msgList.length - 1));
      storedMsgJsonList =
          storedMsg.map((item) => jsonEncode(item.toJson())).toList();
    } else {
      storedMsgJsonList = [];
    }
    await prefs.setStringList("$localKeyPrefix$convID", storedMsgJsonList);
  }

  V2TimMessageReceipt? getMessageReadReceipt(String msgID) {
    return _messageReadReceiptMap[msgID];
  }

  _getMsgReadReceipt(List<V2TimMessage> message) async {
    final msgID = message
        .where((e) => (e.isSelf ?? false) && (e.needReadReceipt ?? false))
        .map((e) => e.msgID ?? '')
        .toList();
    if (msgID.isNotEmpty) {
      final res = await getMessageReadReceipts(msgID);
      if (res.code == 0) {
        final receiptList = res.data;
        if (receiptList != null) {
          for (var item in receiptList) {
            _messageReadReceiptMap[item.msgID!] = item;
          }
        }
      }
      notifyListeners();
    }
  }

  _setMsgReadReceipt(List<V2TimMessage> message) async {
    final msgIDList = List<String>.empty(growable: true);
    for (var item in message) {
      final isSelf = item.isSelf ?? false;
      final needReadReceipt = item.needReadReceipt ?? false;
      if (!isSelf && needReadReceipt && item.msgID != null) {
        msgIDList.add(item.msgID!);
        item.needReadReceipt = false;
      }
    }
    if (msgIDList.isNotEmpty) {
      sendMessageReadReceipts(msgIDList);
    }
  }

  _onReceiveNewMsg(V2TimMessage newMsg) {
    final convID = newMsg.userID ?? newMsg.groupID;
    if (listPosition == HistoryMessagePosition.bottom &&
        unreadCountForConversation == 0) {
      if (convID == _currentSelectedConv && convID != null) {
        markMessageAsRead(
          convID: convID,
          convType: _currentSelectedConvType!,
        );
      }
      if (convID != null) {
        final currentMsg = _messageListMap[convID] ?? [];
        _messageListMap[convID] = [newMsg, ...currentMsg];
        notifyListeners();
        storeMsgToLocal(_messageListMap[convID], convID);
        final messageID = newMsg.msgID;
        final needReadReceipt = newMsg.needReadReceipt ?? false;
        if (needReadReceipt && messageID != null) {
          sendMessageReadReceipts([messageID]);
        }
      }
    } else {
      unreadCountForConversation++;
      if (convID != null) {
        final currentTempMsg = _tempMessageList ?? [];
        _tempMessageList = [newMsg, ...currentTempMsg];
        notifyListeners();
      }
    }
  }

  showLatestUnread(String? convID) {
    if (convID != null) {
      final currentMsg = _messageListMap[convID] ?? [];
      _messageListMap[convID] = [...?_tempMessageList, ...currentMsg];
      unreadCountForConversation = 0;
      listPosition = HistoryMessagePosition.bottom;
      markMessageAsRead(
        convID: convID,
        convType: _currentSelectedConvType!,
      );
      _tempMessageList = [];
      notifyListeners();
      storeMsgToLocal(_messageListMap[convID], convID);
    }
  }

  getOneUnreadMessage(String? convID) {
    if (convID != null) {
      final currentMsg = _messageListMap[convID] ?? [];
      if (_tempMessageList!.length == 1) {
        showLatestUnread(convID);
        return;
      }
      _messageListMap[convID] = [
        _tempMessageList![_tempMessageList!.length - 1],
        ...currentMsg
      ];
      _tempMessageList!.removeAt(_tempMessageList!.length - 1);
      unreadCountForConversation--;
      notifyListeners();
    }
  }

  _onMessageRevoked(String msgID) {
    final activeMessageList = _messageListMap[_currentSelectedConv];
    _messageListMap[_currentSelectedConv] = activeMessageList!.map((item) {
      if (item.msgID == msgID) {
        item.status = MessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED;
      }
      return item;
    }).toList();
    notifyListeners();
  }

  _onRecvC2CReadReceipt(List<V2TimMessageReceipt> receiptList) {
    for (var receipt in receiptList) {
      final convID = receipt.userID;
      final isNotEmpty = _messageListMap[convID]?.isNotEmpty;
      if (isNotEmpty != null && isNotEmpty) {
        _messageListMap[convID] = _messageListMap[convID]!.map((element) {
          final isSelf = element.isSelf ?? false;
          final isPeerRead = element.isPeerRead ?? false;
          if (isSelf && !isPeerRead) {
            element.isPeerRead = true;
          }
          return element;
        }).toList();
      }
    }
    notifyListeners();
  }

  _onRecvMessageReadReceipts(List<V2TimMessageReceipt> receiptList) {
    for (var receipt in receiptList) {
      final msgID = receipt.msgID;
      if (msgID != null) {
        _messageReadReceiptMap[msgID] = receipt;
      }
    }
    notifyListeners();
  }

  _onSendMessageProgress(V2TimMessage messagae, int progress) {
    print("message progress: $progress");
  }

  void initAdvanceListener({V2TimAdvancedMsgListener? listener}) async {
    adVancesMsgListener = V2TimAdvancedMsgListener(
        onRecvC2CReadReceipt: (List<V2TimMessageReceipt> receiptList) {
      _onRecvC2CReadReceipt(receiptList);
      if (listener != null) {
        listener.onRecvC2CReadReceipt(receiptList);
      }
    }, onRecvMessageRevoked: (String msgID) {
      _onMessageRevoked(msgID);
      if (listener != null) {
        listener.onRecvMessageRevoked(msgID);
      }
    }, onRecvNewMessage: (V2TimMessage newMsg) {
      _onReceiveNewMsg(newMsg);
      if (listener != null) {
        listener.onRecvNewMessage(newMsg);
      }
    }, onSendMessageProgress: (V2TimMessage messagae, int progress) {
      _onSendMessageProgress(messagae, progress);
      if (listener != null) {
        listener.onSendMessageProgress(messagae, progress);
      }
    }, onRecvMessageReadReceipts: (List<V2TimMessageReceipt> receiptList) {
      _onRecvMessageReadReceipts(receiptList);
      if (listener != null) {
        listener.onRecvC2CReadReceipt(receiptList);
      }
    }, onRecvMessageModified: (V2TimMessage newMsg) {
      _onMessageModified(newMsg);
      if (listener != null) {
        listener.onRecvMessageModified(newMsg);
      }
    });

    await _messageService.addAdvancedMsgListener(
        listener: adVancesMsgListener!);
  }

  Future<void> removeAdvanceListener() async {
    return _messageService.removeAdvancedMsgListener(
        listener: adVancesMsgListener);
  }

  V2TimMessage _setUserInfoForMessage(V2TimMessage messageInfo, String? id) {
    final loginUserInfo = _coreServices.loginUserInfo;
    messageInfo.faceUrl = loginUserInfo!.faceUrl;
    messageInfo.nickName = loginUserInfo.nickName;
    messageInfo.sender = loginUserInfo.userID;
    messageInfo.status = MessageStatus.V2TIM_MSG_STATUS_SENDING;
    messageInfo.id = id;

    return messageInfo;
  }

  OfflinePushInfo buildMessagePushInfo(
      V2TimMessage message, String convID, ConvType convType) {
    String createJSON(String convID) {
      return "{\"conversationID\": \"$convID\"}";
    }

    String title = chatConfig.notificationTitle;
    String ext = chatConfig.notificationExt != null
        ? chatConfig.notificationExt!(message, convID, convType)
        : (convType == ConvType.c2c
            ? createJSON("c2c_${message.sender}")
            : createJSON("group_$convID"));

    String desc = message.userID ?? message.groupID ?? "";
    String user = message.sender ?? "";
    String messageSummary = "";
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        messageSummary = "自定义消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        messageSummary = "表情消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        messageSummary = "文件消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        messageSummary = "群提示消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        messageSummary = "图片消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        messageSummary = "位置消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        messageSummary = "合并转发消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        messageSummary = "语音消息";
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        messageSummary = message.textElem!.text!;
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        messageSummary = "视频消息";
        break;
    }

    if (chatConfig.notificationBody != null) {
      desc = chatConfig.notificationBody!(message, convID, convType);
    } else {
      desc = messageSummary;
    }

    return OfflinePushInfo.fromJson({
      "title": title,
      "desc": desc,
      "disablePush": false,
      "ext": ext,
      "iOSSound": chatConfig.notificationIOSSound,
      "ignoreIOSBadge": false,
      "androidOPPOChannelID": chatConfig.notificationOPPOChannelID,
    });
  }

  Future<V2TimValueCallback<V2TimMessage>?> reSendMessage(
      {required String msgID,
      required String convID,
      bool? onlineUserOnly}) async {
    final res = await _messageService.reSendMessage(
        msgID: msgID, onlineUserOnly: onlineUserOnly ?? false);
    final messageInfo = res.data;
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    // final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, messageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];
    }
    return res;
  }

  // 注意重发消息需要先删除之前发送失败的图
  Future<V2TimValueCallback<V2TimMessage>?> reSendFailMessage(
      {required V2TimMessage message,
      required String convID,
      required ConvType convType}) async {
    await deleteMsg(message.msgID ?? "", id: message.id);
    int messageType = message.elemType;
    V2TimValueCallback<V2TimMessage>? res;
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      String text = message.textElem!.text!;
      if (_repliedMessage != null) {
        res = await sendReplyMessage(
            text: text, convID: convID, convType: convType);
      } else {
        res = await sendTextMessage(
            text: text, convID: convID, convType: convType);
      }
    }
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_SOUND) {
      String soundPath = message.soundElem!.path!;
      int duration = message.soundElem!.duration!;
      res = await sendSoundMessage(
          soundPath: soundPath,
          duration: duration,
          convID: convID,
          convType: convType);
    }
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE) {
      String imagePath = message.imageElem!.path!;
      res = await sendImageMessage(
          imagePath: imagePath, convID: convID, convType: convType);
    }
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_VIDEO) {
      String videoPath = message.videoElem?.videoPath ?? "";
      int duration = message.videoElem?.duration ?? 0;
      String snapshotPath = message.videoElem?.snapshotPath ?? "";
      res = await sendVideoMessage(
          videoPath: videoPath,
          duration: duration,
          snapshotPath: snapshotPath,
          convID: convID,
          convType: convType);
    }
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_FILE) {
      String filePath = message.fileElem?.path ?? "";
      int size = message.fileElem?.fileSize ?? 0;
      res = await sendFileMessage(
          filePath: filePath, size: size, convID: convID, convType: convType);
    }

    return res;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendTextMessage(
      {required String text,
      required String convID,
      required ConvType convType}) async {
    if (text.isEmpty) {
      return null;
    }
    final textMessageInfo = await _messageService.createTextMessage(text: text);
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, textMessageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textMessageInfo.id as String,
          convType: convType,
          offlinePushInfo: buildMessagePushInfo(
              textMessageInfo.messageInfo!, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?>? sendMessageFromController(
      {required V2TimMessage? messageInfo,
      required String convID,
      required ConvType convType}) {
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    if (messageInfo != null) {
      _messageListMap[convID] = [messageInfo, ...currentHistoryMsgList];
      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: messageInfo.id as String,
          convType: convType,
          offlinePushInfo: buildMessagePushInfo(messageInfo, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendTextAtMessage(
      {required String text,
      required String convID,
      required ConvType convType,
      required List<String> atUserList}) async {
    if (text.isEmpty) {
      return null;
    }
    final textATMessageInfo = await _messageService.createTextAtMessage(
        text: text, atUserList: atUserList);
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    final messageInfo = textATMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, textATMessageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textATMessageInfo.id as String,
          convType: ConvType.group,
          offlinePushInfo: buildMessagePushInfo(
              textATMessageInfo.messageInfo!, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendCustomMessage(
      {required String data,
      required String convID,
      required ConvType convType}) async {
    final textATMessageInfo =
        await _messageService.createCustomMessage(data: data);
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    final messageInfo = textATMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, textATMessageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textATMessageInfo.id as String,
          convType: convType,
          offlinePushInfo: buildMessagePushInfo(
              textATMessageInfo.messageInfo!, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendFaceMessage(
      {required int index,
      required String data,
      required String convID,
      required ConvType convType}) async {
    final textMessageInfo =
        await _messageService.createFaceMessage(index: index, data: data);
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, textMessageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textMessageInfo.id as String,
          convType: convType,
          offlinePushInfo: buildMessagePushInfo(
              textMessageInfo.messageInfo!, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendSoundMessage({
    required String soundPath,
    required int duration,
    required String convID,
    required ConvType convType,
  }) async {
    final soundMessageInfo = await _messageService.createSoundMessage(
        soundPath: soundPath, duration: duration);
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    final messageInfo = soundMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, soundMessageInfo.id!);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...currentHistoryMsgList
      ];

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: soundMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: buildMessagePushInfo(
            soundMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendReplyMessage(
      {required String text,
      required String convID,
      required ConvType convType}) async {
    if (text.isEmpty) {
      return null;
    }
    if (_repliedMessage != null) {
      final textMessageInfo =
          await _messageService.createTextMessage(text: text);
      final messageInfo = textMessageInfo!.messageInfo;
      final receiver = convType == ConvType.c2c ? convID : '';
      final groupID = convType == ConvType.group ? convID : '';
      if (messageInfo != null) {
        final sendMsgRes = await _messageService.sendReplyMessage(
            id: textMessageInfo.id as String,
            replyMessage: _repliedMessage!,
            needReadReceipt: chatConfig.isShowGroupReadingStatus &&
                convType == ConvType.group &&
                chatConfig.groupReadReceiptPermisionList != null &&
                chatConfig.groupReadReceiptPermisionList!.contains(_groupType),
            groupID: groupID,
            receiver: receiver);
        _repliedMessage = null;
        _updateMessage(sendMsgRes, convID, textMessageInfo.id!, convType);

        notifyListeners();
        return sendMsgRes;
      }
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendImageMessage(
      {required String imagePath,
      required String convID,
      required ConvType convType}) async {
    final imageMessageInfo =
        await _messageService.createImageMessage(imagePath: imagePath);
    final messageInfo = imageMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, imageMessageInfo.id);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...?_messageListMap[convID]
      ];

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: imageMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: buildMessagePushInfo(
            imageMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendVideoMessage(
      {required String videoPath,
      required int duration,
      required String snapshotPath,
      required String convID,
      required ConvType convType}) async {
    final videoMessageInfo = await _messageService.createVideoMessage(
        videoPath: videoPath,
        type: 'mp4',
        duration: duration,
        snapshotPath: snapshotPath);
    final messageInfo = videoMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, videoMessageInfo.id);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...?_messageListMap[convID]
      ];

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: videoMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: buildMessagePushInfo(
            videoMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendFileMessage(
      {required String filePath,
      required int size,
      required String convID,
      required ConvType convType}) async {
    final fileMessageInfo = await _messageService.createFileMessage(
        fileName: filePath.split('/').last, filePath: filePath);
    final messageInfo = fileMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, fileMessageInfo.id);
      messageInfoWithSender.fileElem!.fileSize = size;
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...?_messageListMap[convID]
      ];

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: fileMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: buildMessagePushInfo(
            fileMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendLocationMessage(
      {required String desc,
      required double longitude,
      required double latitude,
      required String convID,
      required ConvType convType}) async {
    final locationMessageInfo = await _messageService.createLocationMessage(
        desc: desc, longitude: longitude, latitude: latitude);
    final messageInfo = locationMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          _setUserInfoForMessage(messageInfo, locationMessageInfo.id);
      _messageListMap[convID] = [
        messageInfoWithSender,
        ...?_messageListMap[convID]
      ];

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: locationMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: buildMessagePushInfo(
            locationMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  /// 逐条转发
  sendForwardMessage({
    required List<V2TimConversation> conversationList,
  }) async {
    for (var conversation in conversationList) {
      final convID = conversation.groupID ?? conversation.userID ?? "";
      final convType = conversation.type;
      for (var message in _multiSelectedMessageList) {
        final forwardMessageInfo =
            await _messageService.createForwardMessage(msgID: message.msgID!);
        final messageInfo = forwardMessageInfo!.messageInfo;
        if (messageInfo != null) {
          final messageInfoWithSender =
              _setUserInfoForMessage(messageInfo, forwardMessageInfo.id);
          _messageListMap[convID] = [
            messageInfoWithSender,
            ...?_messageListMap[convID]
          ];
          notifyListeners();
          _sendMessage(
            id: forwardMessageInfo.id!,
            convID: convID,
            convType: convType == 1 ? ConvType.c2c : ConvType.group,
            offlinePushInfo: buildMessagePushInfo(
                forwardMessageInfo.messageInfo!,
                convID,
                convType == 1 ? ConvType.c2c : ConvType.group),
          );
        }
      }
    }
  }

  /// 合并转发
  Future<V2TimValueCallback<V2TimMessage>?> sendMergerMessage({
    required List<V2TimConversation> conversationList,
    required String title,
    required List<String> abstractList,
    required BuildContext context,
  }) async {
    final I18nUtils ttBuild = I18nUtils(context);
    for (var conversation in conversationList) {
      final convID = conversation.groupID ?? conversation.userID ?? "";
      final convType = conversation.type;
      final List<String> msgIDList = _multiSelectedMessageList
          .map((e) => e.msgID ?? "")
          .where((element) => element != "")
          .toList();
      final mergerMessageInfo = await _messageService.createMergerMessage(
          msgIDList: msgIDList,
          title: title,
          abstractList: abstractList,
          compatibleText: ttBuild.imt("该版本不支持此消息"));
      final messageInfo = mergerMessageInfo!.messageInfo;
      if (messageInfo != null) {
        final messageInfoWithSender =
            _setUserInfoForMessage(messageInfo, mergerMessageInfo.id);
        if (_messageListMap[convID] != null) {
          _messageListMap[convID] = [
            messageInfoWithSender,
            ...?_messageListMap[convID]
          ];
        } else {
          _messageListMap[convID] = [
            messageInfoWithSender,
          ];
        }
        notifyListeners();
        return _sendMessage(
          id: mergerMessageInfo.id!,
          convID: convID,
          convType: convType == 1 ? ConvType.c2c : ConvType.group,
          offlinePushInfo: buildMessagePushInfo(mergerMessageInfo.messageInfo!,
              convID, convType == 1 ? ConvType.c2c : ConvType.group),
        );
      }
    }
    return null;
  }

  _onMessageModified(V2TimMessage newMsg, [String? convID]) {
    final activeMessageList = _messageListMap[convID ?? _currentSelectedConv];
    final msgID = newMsg.msgID;
    _messageListMap[_currentSelectedConv] = activeMessageList!.map((item) {
      if (item.msgID == msgID) {
        return newMsg;
      }
      return item;
    }).toList();
    notifyListeners();
    storeMsgToLocal(activeMessageList, _currentSelectedConv);
  }

  Future<void> updateMessageFromController(
      {required String msgID,
      String? receiverID,
      String? groupID,
      ConvType? convType}) async {
    String convID;
    if (convType == null) {
      convID = _currentSelectedConv;
    } else {
      convID = (convType == ConvType.c2c ? receiverID : groupID) ??
          _currentSelectedConv;
    }
    final currentHistoryMsgList = _messageListMap[convID];

    V2TimMessage? newMessage = await _getExistingMessageByID(
        msgID: msgID, convID: convID, convType: convType);
    if (newMessage != null) {
      _onMessageModified(newMessage, convID);
    } else {
      loadData(
        count: HistoryMessageDartConstant.getCount, //20
        userID: convType == ConvType.c2c ? convID : null,
        groupID: convType == ConvType.group ? convID : null,
      );
    }
  }

  Future<V2TimMessage?> _getExistingMessageByID(
      {required String msgID,
      required String convID,
      ConvType? convType}) async {
    final currentHistoryMsgList = _messageListMap[convID];
    final int? targetIndex = currentHistoryMsgList?.indexWhere((item) {
      return item.msgID == msgID;
    });

    if (targetIndex != null &&
        targetIndex != -1 &&
        currentHistoryMsgList != null &&
        currentHistoryMsgList.isNotEmpty) {
      List<V2TimMessage> response;
      if (currentHistoryMsgList.length > targetIndex + 2) {
        response = await _messageService.getHistoryMessageList(
            count: 1,
            getType: HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_NEWER_MSG,
            userID: convType == ConvType.c2c ? convID : null,
            groupID: convType == ConvType.group ? convID : null,
            lastMsgID: currentHistoryMsgList[targetIndex + 1].msgID);
      } else {
        response = await _messageService.getHistoryMessageList(
          count: 2,
          getType: HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
          userID: convType == ConvType.c2c ? convID : null,
          groupID: convType == ConvType.group ? convID : null,
          lastMsgID:
              currentHistoryMsgList[currentHistoryMsgList.length - 3].msgID,
        );
      }

      return response.firstWhere((item) {
        return item.msgID == msgID;
      });
    } else {
      return null;
    }
  }

  _updateMessage(V2TimValueCallback<V2TimMessage> sendMsgRes, String convID,
      String id, ConvType convType) {
    final currentHistoryMsgList = _messageListMap[convID];
    final sendMsgResData = sendMsgRes.data as V2TimMessage;
    if ([80001, 80002].contains(sendMsgRes.code) &&
        sendMsgRes.data?.textElem?.text != null &&
        _setInputField != null) {
      _setInputField!(sendMsgRes.data!.textElem!.text ?? "");
    }
    if (currentHistoryMsgList != null) {
      final findIdIndex =
          currentHistoryMsgList.indexWhere((element) => element.id == id);
      final targetIndex = findIdIndex == -1
          ? currentHistoryMsgList
              .indexWhere((element) => element.msgID == sendMsgResData.msgID)
          : findIdIndex;
      if (targetIndex != -1) {
        _messageListMap[convID]![targetIndex] = sendMsgResData;
      } else {
        _messageListMap[convID] = [sendMsgResData, ...?_messageListMap[convID]];
      }
    } else {
      _messageListMap[convID] = [sendMsgRes.data!];
    }
    if (chatConfig.isShowGroupReadingStatus &&
        convType == ConvType.group &&
        chatConfig.groupReadReceiptPermisionList != null &&
        chatConfig.groupReadReceiptPermisionList!.contains(_groupType)) {
      _messageReadReceiptMap[sendMsgRes.data!.msgID!] =
          V2TimMessageReceipt(timestamp: 0, userID: "", readCount: 0);
    }

    notifyListeners();
    final latestMsgList = _messageListMap[convID];
    storeMsgToLocal(latestMsgList, convID);
  }

  Future<V2TimValueCallback<V2TimMessage>> _sendMessage({
    required String id,
    required String convID,
    required ConvType convType,
    required OfflinePushInfo offlinePushInfo,
  }) async {
    final receiver = convType == ConvType.c2c ? convID : '';
    final groupID = convType == ConvType.group ? convID : '';
    final sendMsgRes = await _messageService.sendMessage(
      id: id,
      receiver: receiver,
      needReadReceipt: chatConfig.isShowGroupReadingStatus &&
          convType == ConvType.group &&
          chatConfig.groupReadReceiptPermisionList != null &&
          chatConfig.groupReadReceiptPermisionList!.contains(_groupType),
      groupID: groupID,
      offlinePushInfo: offlinePushInfo,
    );

    _updateMessage(sendMsgRes, convID, id, convType);

    return sendMsgRes;
  }

  deleteMsg(String msgID, {String? id}) async {
    final res =
        await _messageService.deleteMessageFromLocalStorage(msgID: msgID);
    if (res.code == 0) {
      _messageListMap[_currentSelectedConv]!.removeWhere((element) {
        return element.msgID == msgID || (id != null && element.id == id);
      });
      notifyListeners();
    }
    final latestMsgList = _messageListMap[_currentSelectedConv];
    storeMsgToLocal(latestMsgList, _currentSelectedConv);
  }

  Future<V2TimCallback> revokeMsg(String msgID) async {
    final res = await _messageService.revokeMessage(msgID: msgID);
    if (res.code == 0) {
      _onMessageRevoked(msgID);
    }
    final latestMsgList = _messageListMap[_currentSelectedConv];
    storeMsgToLocal(latestMsgList, _currentSelectedConv);
    return res;
  }

  markMessageAsRead({
    required String convID,
    required int convType,
  }) {
    _unreadCountForConversation = 0;
    if (convType == 1) {
      return _messageService.markC2CMessageAsRead(userID: convID);
    }

    _messageService.markGroupMessageAsRead(groupID: convID);
  }

  Future<List<V2TimMessage>?> downloadMergerMessage(String msgID) {
    return _messageService.downloadMergerMessage(msgID: msgID);
  }

  updateMultiSelectStatus(bool isSelect) {
    _isMultiSelect = isSelect;
    if (!isSelect) {
      _multiSelectedMessageList.clear();
    }
    notifyListeners();
  }

  setRepliedMessage(V2TimMessage? repliedMessage) {
    _repliedMessage = repliedMessage;
    notifyListeners();
  }

  addToMultiSelectedMessageList(V2TimMessage message) {
    _multiSelectedMessageList.add(message);
    notifyListeners();
  }

  removeFromMultiSelectedMessageList(V2TimMessage message) {
    _multiSelectedMessageList.remove(message);
    notifyListeners();
  }

  deleteSelectedMsg() async {
    final msgIDs = _multiSelectedMessageList
        .map((e) => e.msgID ?? "")
        .where((element) => element != "")
        .toList();
    final res = await _messageService.deleteMessages(msgIDs: msgIDs);
    if (res.code == 0) {
      for (var msgID in msgIDs) {
        _messageListMap[_currentSelectedConv]!
            .removeWhere((element) => element.msgID == msgID);
      }
      notifyListeners();

      final latestMsgList = _messageListMap[_currentSelectedConv];
      storeMsgToLocal(latestMsgList, _currentSelectedConv);
    }
  }

  Future<V2TimMessage?> findMessage(String msgID) async {
    final messageListMap = _messageListMap[_currentSelectedConv];
    if (messageListMap != null) {
      final repliedMessage =
          messageListMap.where((element) => element.msgID == msgID).toList();
      if (repliedMessage.isNotEmpty) {
        return repliedMessage.first;
      }
      final message =
          await _messageService.findMessages(messageIDList: [msgID]);
      if (message != null && message.isNotEmpty) {
        return message.first;
      }
    }
    return null;
  }

  setLocalCustomInt(String msgID, int localCustomInt) async {
    final res = await _messageService.setLocalCustomInt(
        msgID: msgID, localCustomInt: localCustomInt);
    if (res.code == 0) {
      _messageListMap[_currentSelectedConv]?.map((item) {
        if (item.msgID == msgID) {
          item.localCustomInt = HistoryMessageDartConstant.read;
        }
        return item;
      }).toList();
    }
    notifyListeners();
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts(
      List<String> messageIDList) {
    return _messageService.getMessageReadReceipts(messageIDList: messageIDList);
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList(String messageID,
          GetGroupMessageReadMemberListFilter fileter, int nextSeq) async {
    final res = await _messageService.getGroupMessageReadMemberList(
        nextSeq: nextSeq, messageID: messageID, filter: fileter);
    return res;
  }

  sendMessageReadReceipts(List<String> messageIDList) async {
    final res = await _messageService.sendMessageReadReceipts(
        messageIDList: messageIDList);
    return res;
  }

  clearHistory() {
    _messageListMap[_currentSelectedConv] = [];
    notifyListeners();
    storeMsgToLocal([], _currentSelectedConv);
  }

  clear() {
    _messageListMap.clear();
    _totalUnreadCount = 0;
    resetData();
  }

  resetData() {
    _isMultiSelect = false;
    _currentSelectedConv = "";
    _editRevokedMsg = "";
    _currentSelectedConvType = null;
    _haveMoreData = true;
    _multiSelectedMessageList.clear();
    _groupType = null;
    _setInputField = null;
  }
}
