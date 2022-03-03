import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

import '../../i18n/i18n_utils.dart';

enum ConvType { group, c2c }

class TUIChatViewModel extends ChangeNotifier {
  final MessageService _messageService = serviceLocator<MessageService>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();
  final Map<String, List<V2TimMessage>?> _messageListMap = {};

  int _totalUnreadCount = 0;
  bool _isMultiSelect = false;
  String _currentSelectedConv = "";
  int? _currentSelectedConvType;
  bool _haveMoreData = true;
  String _currentSelectedMsgId = "";
  final List<V2TimMessage> _multiSelectedMessageList = [];
  V2TimMessage? _repliedMessage;
  String localKeyPrefix = "TUIKit_conversation_stored_";
  String localMsgIDListKey = "TUIKit_conversation_list";

  TUIChatViewModel() {
    initMessageMapFromLocal();
  }

  Map<String, List<V2TimMessage>?> get messageListMap {
    return _messageListMap;
  }

  bool get haveMoreData {
    return _haveMoreData;
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

  V2TimMessage? get repliedMessage {
    return _repliedMessage;
  }

  set currentSelectedMsgId(String msgID) {
    _currentSelectedMsgId = msgID;
    notifyListeners();
  }

  set totalUnReadCount(int newValue) {
    _totalUnreadCount = newValue;
    notifyListeners();
  }

  List<V2TimMessage> get multiSelectedMessageList {
    return _multiSelectedMessageList;
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

  void loadData({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
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
        ...response!
      ]; // 拼接拉取更多历史
    } else {
      _messageListMap[convID!] = response; // 首屏默认历史消息
      // put the last 20 messages to local
      storeMsgToLocal(response, convID, ifEmptyHistory);
    }
    if (response!.isEmpty || response.length < 20) {
      _haveMoreData = false;
    }
    _currentSelectedConv = convID;
    _currentSelectedConvType = userID != null ? 1 : 2;
    notifyListeners();

    // put the last 20 messages to local
    // final latestMsgList = _messageListMap[convID];
    // storeMsgToLocal(latestMsgList, convID, ifEmptyHistory);
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

  _onReceiveNewMsg(V2TimMessage newMsg) {
    final convID = newMsg.userID ?? newMsg.groupID;
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

  _onSendMessageProgress(V2TimMessage messagae, int progress) {
    print("message progress: $progress");
  }

  void initAdvanceListener({V2TimAdvancedMsgListener? listener}) async {
    final adVancesMsgListener = V2TimAdvancedMsgListener(
      onRecvC2CReadReceipt: (List<V2TimMessageReceipt> receiptList) {
        _onRecvC2CReadReceipt(receiptList);
        if (listener != null) {
          listener.onRecvC2CReadReceipt(receiptList);
        }
      },
      onRecvMessageRevoked: (String msgID) {
        _onMessageRevoked(msgID);
        if (listener != null) {
          listener.onRecvMessageRevoked(msgID);
        }
      },
      onRecvNewMessage: (V2TimMessage newMsg) {
        _onReceiveNewMsg(newMsg);
        if (listener != null) {
          listener.onRecvNewMessage(newMsg);
        }
      },
      onSendMessageProgress: (V2TimMessage messagae, int progress) {
        _onSendMessageProgress(messagae, progress);
        if (listener != null) {
          listener.onSendMessageProgress(messagae, progress);
        }
      },
    );

    await _messageService.addAdvancedMsgListener(listener: adVancesMsgListener);
  }

  Future<void> removeAdvanceListener(
      {V2TimAdvancedMsgListener? listener}) async {
    return _messageService.removeAdvancedMsgListener(listener: listener);
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

  sendTextMessage(
      {required String text,
      required String convID,
      required ConvType convType}) async {
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
      _sendMessage(
          convID: convID, id: textMessageInfo.id as String, convType: convType);
    }
  }

  sendSoundMessage({
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
      _sendMessage(
          convID: convID,
          id: soundMessageInfo.id as String,
          convType: convType);
    }
  }

  sendReplyMessage(
      {required String text,
      required String convID,
      required ConvType convType}) async {
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
            groupID: groupID,
            receiver: receiver);
        _repliedMessage = null;
        _updateMessage(sendMsgRes, convID, textMessageInfo.id!);
      }
    }
  }

  sendImageMessage(
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
      _sendMessage(
          convID: convID,
          id: imageMessageInfo.id as String,
          convType: convType);
    }
  }

  sendVideoMessage(
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
      _sendMessage(
          convID: convID,
          id: videoMessageInfo.id as String,
          convType: convType);
    }
  }

  sendFileMessage(
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
      _sendMessage(
          convID: convID, id: fileMessageInfo.id as String, convType: convType);
    }
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
              convType: convType == 1 ? ConvType.c2c : ConvType.group);
        }
      }
    }
  }

  /// 合并转发
  sendMergerMessage({
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
        _sendMessage(
            id: mergerMessageInfo.id!,
            convID: convID,
            convType: convType == 1 ? ConvType.c2c : ConvType.group);
      }
    }
  }

  _updateMessage(
      V2TimValueCallback<V2TimMessage> sendMsgRes, String convID, String id) {
    final currentHistoryMsgList = _messageListMap[convID];
    final sendMsgResData = sendMsgRes.data as V2TimMessage;
    if (currentHistoryMsgList != null) {
      final targetIndex =
          currentHistoryMsgList.indexWhere((element) => element.id == id);
      if (targetIndex != -1) {
        _messageListMap[convID]![targetIndex] = sendMsgResData;
      } else {
        _messageListMap[convID] = [sendMsgResData, ...?_messageListMap[convID]];
      }
    } else {
      _messageListMap[convID] = [sendMsgRes.data!];
    }
    notifyListeners();

    final latestMsgList = _messageListMap[convID];
    storeMsgToLocal(latestMsgList, convID);
  }

  _sendMessage(
      {required String id,
      required String convID,
      required ConvType convType}) async {
    final receiver = convType == ConvType.c2c ? convID : '';
    final groupID = convType == ConvType.group ? convID : '';
    final sendMsgRes = await _messageService.sendMessage(
        id: id, receiver: receiver, groupID: groupID);
    _updateMessage(sendMsgRes, convID, id);
  }

  deleteMsg(String msgID) async {
    final res =
        await _messageService.deleteMessageFromLocalStorage(msgID: msgID);
    if (res.code == 0) {
      _messageListMap[_currentSelectedConv]!
          .removeWhere((element) => element.msgID == msgID);
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

  markMessageAsRead({required String convID, required int convType}) {
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

  clearHistory() {
    _messageListMap[_currentSelectedConv] = [];
    notifyListeners();
    storeMsgToLocal([], _currentSelectedConv);
  }

  clear() {
    _messageListMap.clear();
    _totalUnreadCount = 0;
    _isMultiSelect = false;
    _currentSelectedConv = "";
    _currentSelectedConvType = null;
    _haveMoreData = true;
    _multiSelectedMessageList.clear();
  }
}
