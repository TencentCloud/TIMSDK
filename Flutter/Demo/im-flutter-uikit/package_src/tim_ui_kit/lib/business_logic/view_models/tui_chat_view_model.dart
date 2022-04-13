import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_tips_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/group_change_info_type.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/enum/offlinePushInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';

import '../../i18n/i18n_utils.dart';

enum ConvType { group, c2c }

class TUIChatViewModel extends ChangeNotifier {
  final MessageService _messageService = serviceLocator<MessageService>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final Map<String, List<V2TimMessage>?> _messageListMap = {};
  final Map<String, int> _messageListProgressMap = {};

  int _totalUnreadCount = 0;
  bool _isMultiSelect = false;
  String _currentSelectedConv = "";
  int? _currentSelectedConvType;
  bool _haveMoreData = true;
  String _currentSelectedMsgId = "";
  String _editRevokedMsg = "";
  final List<V2TimMessage> _multiSelectedMessageList = [];
  V2TimMessage? _repliedMessage;
  String localKeyPrefix = "TUIKit_conversation_stored_";
  String localMsgIDListKey = "TUIKit_conversation_list";
  int _jumpTimestamp = 0;
  String _conversationShowName = "";
  V2TimAdvancedMsgListener? adVancesMsgListener;

  TUIChatViewModel() {
    initMessageMapFromLocal();
  }

  Map<String, int> get messageListProgressMap {
    return _messageListProgressMap;
  }

  Map<String, List<V2TimMessage>?> get messageListMap {
    return _messageListMap;
  }

  bool get haveMoreData {
    return _haveMoreData;
  }

  int get jumpTimestamp {
    return _jumpTimestamp;
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

  String get editRevokedMsg {
    return _editRevokedMsg;
  }

  String get currentSelectedConv {
    return _currentSelectedConv;
  }

  String get conversationName {
    return _conversationShowName;
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

  set editRevokedMsg(String msg) {
    _editRevokedMsg = msg;
    notifyListeners();
  }

  set jumpTimestamp(int timestamp) {
    _jumpTimestamp = timestamp;
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

  int getMessageProgress(String? msgID) {
    return _messageListProgressMap[msgID] ?? 0;
  }

  setMessageProgress(String msgID, int progress) {
    _messageListProgressMap[msgID] = progress;
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

  Future<void> loadData(
      {HistoryMsgGetTypeEnum getType =
          HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
      String? userID,
      String? groupID,
      int lastMsgSeq = -1,
      required int count,
      String? lastMsgID,
      String? conversationShowName}) async {
    if (lastMsgID == null) {
      _jumpTimestamp = 0;
    }
    _conversationShowName = conversationShowName ?? "";
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
    return;
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
      final isGroupTipsMsg =
          newMsg.elemType == MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS;
      if (isGroupTipsMsg) {
        final isChangeGroupInfo = newMsg.groupTipsElem?.type ==
            GroupTipsElemType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE;
        if (isChangeGroupInfo) {
          final groupChangeInfoList =
              newMsg.groupTipsElem?.groupChangeInfoList ?? [];
          final groupNameChangeInfo = groupChangeInfoList.firstWhere(
              (element) =>
                  element?.type ==
                  GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME);
          if (groupNameChangeInfo != null &&
              groupNameChangeInfo.value != null) {
            _conversationShowName = groupNameChangeInfo.value!;
          }
        }
      }
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
    adVancesMsgListener = V2TimAdvancedMsgListener(
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

  OfflinePushInfo buildMessagePushInfo(V2TimMessage message) {
    String title = "收到一条消息";
    String desc = "";
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

    desc = "$user：$messageSummary";

    return OfflinePushInfo.fromJson({
      "title": title,
      "desc": desc,
      "disablePush": false,
      "ext": "",
      "iOSSound": "",
      "ignoreIOSBadge": false,
      "androidOPPOChannelID": "",
    });
  }

  V2TimGroupListener? _groupListener;

  addGroupListener() {
    _groupListener = V2TimGroupListener(
      onGroupInfoChanged: (groupID, changeInfos) {
        if (groupID == _currentSelectedConv) {
          final groupNameChangeInfo = changeInfos.firstWhere((element) =>
              element.type ==
              GroupChangeInfoType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME);
          if (groupNameChangeInfo.value != null) {
            _conversationShowName = groupNameChangeInfo.value!;
            notifyListeners();
          }
        }
      },
    );
    if (_groupListener != null) {
      _groupServices.addGroupListener(listener: _groupListener!);
    }
  }

  removeGroupListener() {
    _groupServices.removeGroupListener(listener: _groupListener);
  }

  V2TimFriendshipListener? _friendshipListener;

  addFriendInfoChangeListener() {
    _friendshipListener = V2TimFriendshipListener(
      onFriendInfoChanged: (infoList) {
        final changedInfo = infoList.firstWhere(
          (element) => element.userID == _currentSelectedConv,
        );
        if (changedInfo.friendRemark != null) {
          _conversationShowName = changedInfo.friendRemark!;
        }
        notifyListeners();
      },
    );
    if (_friendshipListener != null) {
      _friendshipServices.setFriendshipListener(listener: _friendshipListener!);
    }
  }

  removeFriendChangeListener() {
    _friendshipServices.removeFriendListener(listener: _friendshipListener);
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
            textMessageInfo.messageInfo!,
          ));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?>? sendMessageFromController({required V2TimMessage? messageInfo,
    required String convID,
    required ConvType convType}){
    final currentHistoryMsgList = _messageListMap[convID] ?? [];
    if (messageInfo != null) {
      _messageListMap[convID] = [
        messageInfo,
        ...currentHistoryMsgList
      ];
      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: messageInfo.id as String,
          convType: convType,
          offlinePushInfo: buildMessagePushInfo(
            messageInfo,
          ));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendTextAtMessage(
      {required String text,
      required String convID,
      required List<String> atUserList}) async {
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
            textATMessageInfo.messageInfo!,
          ));
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
            textATMessageInfo.messageInfo!,
          ));
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
            textMessageInfo.messageInfo!,
          ));
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
        offlinePushInfo: buildMessagePushInfo(soundMessageInfo.messageInfo!),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendReplyMessage(
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
        offlinePushInfo: buildMessagePushInfo(imageMessageInfo.messageInfo!),
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
        offlinePushInfo: buildMessagePushInfo(videoMessageInfo.messageInfo!),
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
        offlinePushInfo: buildMessagePushInfo(fileMessageInfo.messageInfo!),
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
        offlinePushInfo: buildMessagePushInfo(locationMessageInfo.messageInfo!),
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
            offlinePushInfo:
                buildMessagePushInfo(forwardMessageInfo.messageInfo!),
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
          offlinePushInfo: buildMessagePushInfo(mergerMessageInfo.messageInfo!),
        );
      }
    }
    return null;
  }

  _updateMessage(
      V2TimValueCallback<V2TimMessage> sendMsgRes, String convID, String id) {
    final currentHistoryMsgList = _messageListMap[convID];
    final sendMsgResData = sendMsgRes.data as V2TimMessage;
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
      groupID: groupID,
      offlinePushInfo: offlinePushInfo,
    );

    _updateMessage(sendMsgRes, convID, id);

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
    _editRevokedMsg = "";
    _currentSelectedConvType = null;
    _haveMoreData = true;
    _multiSelectedMessageList.clear();
  }
}
