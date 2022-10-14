// ignore_for_file: avoid_print, unnecessary_getters_setters, unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_model_tools.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';

import 'package:tim_ui_kit/ui/utils/message.dart';

enum ConvType { none, c2c, group }

enum HistoryMessagePosition { bottom, inTwoScreen, awayTwoScreen }

class CurrentConversation {
  final String conversationID;
  final ConvType conversationType;

  CurrentConversation(this.conversationID, this.conversationType);
}

class TUIChatGlobalModel extends ChangeNotifier {
  final MessageService _messageService = serviceLocator<MessageService>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final Map<String, List<V2TimMessage>?> _messageListMap = {};
  final Map<String, V2TimMessageReceipt> _messageReadReceiptMap = {};
  final Map<String, List<V2TimMessage>?> _tempMessageListMap = {};
  final Map<String, int> _messageListProgressMap = {};
  final Map<String, dynamic> _preloadImageMap = {};
  final Map<String, HistoryMessagePosition> _historyMessagePositionMap = {};
  List<CurrentConversation> _currentConversationList = [];
  Map<String, dynamic> get preloadImageMap => _preloadImageMap;

  ChatLifeCycle? _lifeCycle;
  bool _isDownloading = false;
  int _totalUnreadCount = 0;
  String localKeyPrefix = "TUIKit_conversation_stored_";
  String localMsgIDListKey = "TUIKit_conversation_list";

  late V2TimAdvancedMsgListener advancedMsgListener;
  int _unreadCountForConversation = 0;
  int testCount = 0;
  TIMUIKitChatConfig chatConfig = const TIMUIKitChatConfig();
  List<V2TimGroupApplication>? _groupApplicationList;
  String Function(V2TimMessage message)? _abstractMessageBuilder;
  final Map<String, int> _c2cMessageEditStatusMap =
      Map.from({}); // 0 normal 1 sending
  final Map<String, bool> _c2cMessageFromUserActiveMap = Map.from({});
  final Map<String, Timer> _c2cMessageActiveTimer = Map.from({});
  bool _showC2cMessageEditStaus = true;
  final Map<String, Timer> _c2cMessageStatusShowTimer = Map.from({});
  Map<String, List> loadingMessage = {};

  TUIChatGlobalModel() {
    advancedMsgListener = V2TimAdvancedMsgListener(
        onRecvC2CReadReceipt: (List<V2TimMessageReceipt> receiptList) {
      _onReceiveC2CReadReceipt(receiptList);
    }, onRecvMessageRevoked: (String msgID) {
      onMessageRevoked(msgID);
    }, onRecvNewMessage: (V2TimMessage newMsg) {
      _onReceiveNewMsg(newMsg);
    }, onSendMessageProgress: (V2TimMessage messagae, int progress) {
      _onSendMessageProgress(messagae, progress);
    }, onRecvMessageReadReceipts: (List<V2TimMessageReceipt> receiptList) {
      _onReceiveMessageReadReceipts(receiptList);
    }, onRecvMessageModified: (V2TimMessage newMsg) {
      onMessageModified(newMsg);
    });
    // Future.delayed(const Duration(milliseconds: 200)).then((value) => initMessageMapFromLocal());
  }

  bool get isDownloading => _isDownloading;

  Map<String, int> get messageListProgressMap {
    return _messageListProgressMap;
  }

  Map<String, List<V2TimMessage>?> get messageListMap {
    return _messageListMap;
  }

  int get totalUnReadCount {
    return _totalUnreadCount;
  }

  int get unreadCountForConversation => _unreadCountForConversation;

  List<V2TimGroupApplication> get groupApplicationList =>
      _groupApplicationList ?? [];

  String Function(V2TimMessage message)? get abstractMessageBuilder =>
      _abstractMessageBuilder;

  Map<String, List<V2TimMessage>?> get tempMessageListMap =>
      _tempMessageListMap;

  Map<String, V2TimMessageReceipt> get messageReadReceiptMap =>
      _messageReadReceiptMap;

  String get currentSelectedConv => _currentConversationList.isNotEmpty
      ? _currentConversationList[_currentConversationList.length - 1]
          .conversationID
      : "";

  ConvType? get currentSelectedConvType => _currentConversationList.isNotEmpty
      ? _currentConversationList[_currentConversationList.length - 1]
          .conversationType
      : null;

  setCurrentConversation(CurrentConversation value) {
    _currentConversationList.add(value);
    notifyListeners();
  }

  clearCurrentConversation() {
    _currentConversationList.removeLast();
    notifyListeners();
  }

  V2TimMessageReceipt? getMessageReadReceipt(String msgID) {
    return messageReadReceiptMap[msgID];
  }

  setShowC2cEditStatus(bool show) {
    _showC2cMessageEditStaus = show;
  }

  /// set edit status from chats
  setC2cMessageEditStatus(String userID, int status) {
    _c2cMessageEditStatusMap[userID] = status;
    if (status == 1) {
      if (_c2cMessageStatusShowTimer[userID] != null) {
        if (_c2cMessageStatusShowTimer[userID]!.isActive) {
          _c2cMessageStatusShowTimer[userID]!.cancel();
          _c2cMessageEditStatusMap[userID] = 0;
        }
      }
      _c2cMessageStatusShowTimer[userID] =
          Timer.periodic(const Duration(seconds: 5), (timer) {
        _c2cMessageEditStatusMap[userID] = 0;
        Timer? t = _c2cMessageStatusShowTimer[userID];
        if (t != null && t.isActive) {
          // 取消当前的定时器
          t.cancel();
        }
      });
    }
    notifyListeners();
  }

  int getC2cMessageEditStatus(String userID) {
    return _c2cMessageEditStatusMap[userID] ?? 0;
  }

  set abstractMessageBuilder(String Function(V2TimMessage message)? value) {
    _abstractMessageBuilder = value;
  }

  set lifeCycle(ChatLifeCycle? value) {
    _lifeCycle = value;
  }

  set groupApplicationList(List<V2TimGroupApplication> value) {
    _groupApplicationList = value;
  }

  set unreadCountForConversation(int value) {
    _unreadCountForConversation = value;
    notifyListeners();
  }

  set totalUnReadCount(int newValue) {
    _totalUnreadCount = newValue;
    notifyListeners();
  }

  setChatConfig(TIMUIKitChatConfig config) {
    chatConfig = config;
  }

  initMessageMapFromLocalDatabase(
      List<V2TimConversation?> conversations) async {
    int index = 0;
    for (V2TimConversation? conversationItem in conversations) {
      if (conversationItem == null || conversationItem.type == null) {
        return;
      }
      final conversationID = conversationItem.userID ??
          conversationItem.groupID ??
          conversationItem.conversationID;
      if (messageListMap[conversationID] == null ||
          messageListMap[conversationID]!.isEmpty) {
        index++;
        Future.delayed(Duration(milliseconds: 500 * index), () {
          preloadMessageForConversation(
              conversationID: conversationID,
              conversationType: ConvType.values[conversationItem.type!]);
        });
      }
    }
  }

  preloadMessageForConversation({
    required ConvType conversationType,
    required String conversationID,
  }) async {
    final response = await _messageService.getHistoryMessageList(
        count: 10,
        getType: HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
        userID: conversationType == ConvType.c2c ? conversationID : null,
        messageTypeList: [1],
        groupID: conversationType == ConvType.group ? conversationID : null);
    if (_messageListMap[conversationID] == null ||
        _messageListMap[conversationID]!.isEmpty) {
      _messageListMap[conversationID] = response;
    }
  }

  clearMessageMapFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localMsgIDList = prefs.getStringList(localMsgIDListKey);

    if (localMsgIDList != null) {
      for (String convID in localMsgIDList) {
        prefs.remove("$localKeyPrefix$convID");
      }
    }

    prefs.remove(localMsgIDListKey);
  }

  Future<void> updateMessageFromController(
      {required String msgID,
      required String conversationID,
      required ConvType conversationType}) async {
    final TUIChatModelTools tools = serviceLocator<TUIChatModelTools>();
    V2TimMessage? newMessage = await tools.getExistingMessageByID(
        msgID: msgID,
        conversationID: conversationID,
        conversationType: conversationType);
    if (newMessage != null) {
      onMessageModified(newMessage, currentSelectedConv);
    }
  }

  Future<bool> refreshCurrentHistoryListForConversation(
      {HistoryMsgGetTypeEnum getType =
          HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
      int lastMsgSeq = -1,
      required int count,
      String? lastMsgID,
      required String convID,
      required ConvType convType}) async {
    final currentHistoryMsgList = messageListMap[convID];
    final response = await _messageService.getHistoryMessageList(
        count: count,
        getType: getType,
        userID: convType == ConvType.c2c ? convID : null,
        groupID: convType == ConvType.group ? convID : null,
        lastMsgID: lastMsgID,
        lastMsgSeq: lastMsgSeq);
    if (lastMsgID != null && currentHistoryMsgList != null) {
      final newList = [...currentHistoryMsgList, ...response];
      final List<V2TimMessage> msgList =
          await _lifeCycle?.didGetHistoricalMessageList(newList) ?? newList;
      setMessageList(convID, msgList);
    } else {
      final List<V2TimMessage> messageList =
          await _lifeCycle?.didGetHistoricalMessageList(response) ?? response;
      setMessageList(convID, messageList);
      // The messages in first screen
    }
    notifyListeners();
    return true;
  }

  clearData() {
    _messageListMap.clear();
    _currentConversationList.clear();
    _totalUnreadCount = 0;
    _groupApplicationList?.clear();
    _totalUnreadCount = 0;
    _messageReadReceiptMap.clear();
    _tempMessageListMap.clear();
    _messageListProgressMap.clear();
    notifyListeners();
  }

  _preLoadImage(List<V2TimMessage> msgList) {
    List<V2TimMessage> needPreViewList =
        msgList.sublist(0, max(0, min(5, msgList.length - 1)));
    for (var msgItem in needPreViewList) {
      V2TimImage? getImageFromList(V2_TIM_IMAGE_TYPES_ENUM imgType) {
        V2TimImage? img = MessageUtils.getImageFromImgList(
            msgItem.imageElem?.imageList,
            HistoryMessageDartConstant.imgPriorMap[imgType] ??
                HistoryMessageDartConstant.oriImgPrior);
        return img;
      }

      V2TimImage? originalImg = getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.small);
      if (originalImg?.localUrl != null && originalImg!.localUrl != "") {
        try {
          ImageConfiguration configuration = const ImageConfiguration();
          final image = FileImage(File((originalImg.localUrl!)));

          image.resolve(configuration).addListener(
              ImageStreamListener((ImageInfo image, bool synchronousCall) {
            final tempImg = image.image;
            _preloadImageMap[msgItem.seq! +
                msgItem.timestamp.toString() +
                (msgItem.msgID ?? "")] = tempImg;
            print("cacheImage ${msgItem.msgID}");
          }));
        } catch (e) {
          print("cacheImage error ${msgItem.msgID}");
        }
      }
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

  _editStatusCheck(V2TimMessage msg) {
    bool isStatusMessage = false;
    if (msg.customElem != null && msg.groupID == null) {
      V2TimCustomElem customElem = msg.customElem!;
      String sender = msg.sender ?? "";
      if (customElem.data!.isNotEmpty) {
        try {
          Map<String, dynamic>? data = json.decode(customElem.data ?? "");
          if (data != null) {
            String businessID = data["businessID"];
            int? userAction = data["userAction"];
            String? actionParam = data["actionParam"];
            if (businessID == "user_typing_status") {
              int? typingStatus = data["typingStatus"];
              if (sender != "") {
                if (typingStatus != null) {
                  setC2cMessageEditStatus(sender, typingStatus);
                } else {
                  // 兼容旧版本逻辑
                  if (userAction != null) {
                    if (userAction == 14) {
                      if (actionParam != null) {
                        setC2cMessageEditStatus(sender,
                            actionParam == "EIMAMSG_InputStatus_Ing" ? 1 : 0);
                      }
                    }
                  }
                }
              }
              return true;
            }
          }
        } catch (err) {
          // err;
        }
      }
    }
    return isStatusMessage;
  }

  _checkFromUserisActive(V2TimMessage msg) async {
    // check message is c2c message and message cloudcustomdata field is not null
    if (msg.groupID == null && msg.cloudCustomData != null) {
      try {
        Map<String, dynamic> data = json.decode(msg.cloudCustomData ?? "");
        Map<String, dynamic>? messageFeature = data["messageFeature"];
        print(data);
        if (messageFeature != null) {
          int needTyping = messageFeature["needTyping"];
          if (needTyping == 1) {
            _c2cMessageFromUserActiveMap[msg.sender ?? ""] = true;

            if (_c2cMessageActiveTimer[msg.sender ?? ""] != null) {
              Timer? t = _c2cMessageActiveTimer[msg.sender ?? ""];
              if (t != null && t.isActive) {
                //取消原来的定时器
                t.cancel();
              }
            }
            _c2cMessageActiveTimer[msg.sender ?? ""] =
                Timer.periodic(const Duration(seconds: 30), (timer) {
              _c2cMessageFromUserActiveMap[msg.sender ?? ""] = false;
              Timer? t = _c2cMessageActiveTimer[msg.sender ?? ""];
              if (t != null && t.isActive) {
                // 取消当前的定时器
                t.cancel();
              }
            });
          }
        }
      } catch (err) {
        // err
      }
    }
  }

  sendEditStatusMessage(bool isEditing, String toUser) async {
    if (!_showC2cMessageEditStaus) {
      return;
    }
    if (!(_c2cMessageFromUserActiveMap[toUser] ?? false)) {
      print("to user is not online");
      return;
    }
    V2TimMsgCreateInfoResult? res = await _messageService.createCustomMessage(
        data: json.encode({
      "businessID": "user_typing_status",
      "typingStatus": isEditing == true ? 1 : 0,
      "userAction": 14,
      "version": 0,
      "actionParam": isEditing == true
          ? "EIMAMSG_InputStatus_Ing"
          : "EIMAMSG_InputStatus_End"
    }));
    if (res != null) {
      _sendMessage(
        id: res.id!,
        convID: toUser,
        convType: ConvType.c2c,
        onlineUserOnly: true,
        isEditStatusMessage: true,
      );
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

  cancelAllTimer() {
    _c2cMessageActiveTimer.forEach((key, value) {
      if (value.isActive) {
        value.cancel();
      }
    });
    _c2cMessageStatusShowTimer.forEach((key, value) {
      if (value.isActive) {
        value.cancel();
      }
    });
  }

  _onReceiveNewMsg(V2TimMessage msgComing) async {
    final V2TimMessage? newMsg = _lifeCycle?.newMessageWillMount != null
        ? await _lifeCycle?.newMessageWillMount(msgComing)
        : msgComing;
    if (newMsg == null) {
      return;
    }
    // check the message is editing status msg. and flutter is only support the latest version
    bool isEditMessage = _editStatusCheck(msgComing);

    // if the message is edit status message dont up to screen
    if (isEditMessage) {
      return;
    }

    _checkFromUserisActive(msgComing);
    final convID = newMsg.userID ?? newMsg.groupID;
    if (convID != null && convID == currentSelectedConv) {
      if (getMessageListPosition(convID) == HistoryMessagePosition.bottom &&
          unreadCountForConversation == 0) {
        markMessageAsRead(
          convID: convID,
          convType: currentSelectedConvType!,
        );
        final currentMsg = _messageListMap[convID] ?? [];
        _messageListMap[convID] = [newMsg, ...currentMsg];
        notifyListeners();
        final messageID = newMsg.msgID;
        final needReadReceipt = newMsg.needReadReceipt ?? false;
        if (needReadReceipt &&
            messageID != null &&
            msgComing.groupID != null &&
            chatConfig.isReportGroupReadingStatus) {
          // only group message send message read receipt
          sendMessageReadReceipts([messageID]);
        }
      } else {
        if (convID == currentSelectedConv) {
          unreadCountForConversation++;
          final currentTempMsg = _tempMessageListMap[convID] ?? [];
          _tempMessageListMap[convID] = [newMsg, ...currentTempMsg];
          notifyListeners();
        }
      }
    } else if (convID != null) {
      final currentMsg = _messageListMap[convID] ?? [];
      _messageListMap[convID] = [newMsg, ...currentMsg];
      notifyListeners();
    }
  }

  sendMessageReadReceipts(List<String> messageIDList) async {
    final res = await _messageService.sendMessageReadReceipts(
        messageIDList: messageIDList);
    return res;
  }

  onMessageRevoked(String msgID, [String? convID]) {
    final activeMessageList = _messageListMap[convID ?? currentSelectedConv];
    if (activeMessageList != null) {
      final findeIndex =
          activeMessageList.indexWhere((element) => element.msgID == msgID);
      if (findeIndex != -1) {
        final findeIndex =
            activeMessageList.indexWhere((element) => element.msgID == msgID);
        if (findeIndex != -1) {
          final targetItem = activeMessageList[findeIndex];
          targetItem.status = MessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED;
          targetItem.id = DateTime.now().millisecondsSinceEpoch.toString();
          activeMessageList[findeIndex] = targetItem;
        }
      }
      _messageListMap[convID ?? currentSelectedConv] = activeMessageList;
      notifyListeners();
    }
  }

  onMessageModified(V2TimMessage modifiedMessage, [String? convID]) async {
    modifiedMessage.id = DateTime.now().millisecondsSinceEpoch.toString();
    final activeMessageList = _messageListMap[convID ?? currentSelectedConv];
    if (activeMessageList == null || activeMessageList.isEmpty) {
      return;
    }
    final V2TimMessage newMsg =
        await _lifeCycle?.modifiedMessageWillMount(modifiedMessage) ??
            modifiedMessage;
    final msgID = newMsg.msgID;
    _messageListMap[currentSelectedConv] = activeMessageList.map((item) {
      if (item.msgID == msgID) {
        return newMsg;
      }
      return item;
    }).toList();
    notifyListeners();
  }

  _onReceiveC2CReadReceipt(List<V2TimMessageReceipt> receiptList) {
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

  _onReceiveMessageReadReceipts(List<V2TimMessageReceipt> receiptList) {
    try {
      for (var receipt in receiptList) {
        final msgID = receipt.msgID;
        if (msgID != null) {
          _messageReadReceiptMap[msgID] = receipt;
        }
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  _onSendMessageProgress(V2TimMessage messagae, int progress) {
    print("message progress: $progress");
  }

  void addAdvancedMsgListener() {
    _messageService.addAdvancedMsgListener(listener: advancedMsgListener);
  }

  void removeAdvanceMsgListener() {
    _messageService.removeAdvancedMsgListener(listener: advancedMsgListener);
  }

  markMessageAsRead({
    required String convID,
    required ConvType convType,
  }) async {
    _unreadCountForConversation = 0;
    if (convType == ConvType.c2c) {
      return _messageService.markC2CMessageAsRead(userID: convID);
    }

    _messageService.markGroupMessageAsRead(groupID: convID);
  }

  Future<V2TimValueCallback<V2TimMessage>?>? sendMessageFromController({
    required V2TimMessage? messageInfo,
    required ConvType convType,
    required String convID,
    ValueChanged<String>? setInputField,
    OfflinePushInfo? offlinePushInfo,
  }) {
    final TUIChatModelTools tools = serviceLocator<TUIChatModelTools>();
    List<V2TimMessage> currentHistoryMsgList = _messageListMap[convID] ?? [];
    if (messageInfo != null) {
      final messageInfoWithSender = messageInfo.sender == null
          ? tools.setUserInfoForMessage(messageInfo, messageInfo.id!)
          : messageInfo;
      currentHistoryMsgList = [messageInfoWithSender, ...currentHistoryMsgList];
      setMessageList(convID, currentHistoryMsgList);
      if (loadingMessage[convID] != null &&
          loadingMessage[convID]!.isNotEmpty) {
        loadingMessage[convID]!.add(messageInfoWithSender);
      } else {
        loadingMessage[convID] = <V2TimMessage>[messageInfoWithSender];
      }
      return _sendMessage(
        convID: convID,
        setInputField: setInputField,
        id: messageInfo.id as String,
        convType: ConvType.values[convType.index],
        offlinePushInfo: offlinePushInfo ??
            tools.buildMessagePushInfo(
                messageInfo, convID, ConvType.values[convType.index]),
      );
    }
    return null;
  }

  Future<bool> setLocalCustomData(
      String msgID, String localCustomData, String conversationID) async {
    final res = await _messageService.setLocalCustomData(
        msgID: msgID, localCustomData: localCustomData);
    List<V2TimMessage> messageList = _messageListMap[conversationID] ?? [];
    if (res.code == 0) {
      messageList = messageList.map((item) {
        if (item.msgID == msgID) {
          item.localCustomData = localCustomData;
        }
        return item;
      }).toList();
      setMessageList(conversationID, messageList);
      return true;
    }
    return false;
  }

  Future<bool> setLocalCustomInt(
      String msgID, int localCustomInt, String conversationID) async {
    final res = await _messageService.setLocalCustomInt(
        msgID: msgID, localCustomInt: localCustomInt);
    List<V2TimMessage> messageList = _messageListMap[conversationID] ?? [];
    if (res.code == 0) {
      messageList = messageList.map((item) {
        if (item.msgID == msgID) {
          item.localCustomInt = HistoryMessageDartConstant.read;
        }
        return item;
      }).toList();
      setMessageList(conversationID, messageList);
      return true;
    }
    return false;
  }

  Future<V2TimValueCallback<V2TimMessage>> _sendMessage({
    required String id,
    required String convID,
    required ConvType convType,
    OfflinePushInfo? offlinePushInfo,
    bool? onlineUserOnly = false,
    bool? isEditStatusMessage = false,
    GroupReceiptAllowType? groupType,
    ValueChanged<String>? setInputField,
  }) async {
    String receiver = convType == ConvType.c2c ? convID : '';
    String groupID = convType == ConvType.group ? convID : '';
    final oldGroupType =
        groupType != null ? GroupReceptAllowType.values[groupType.index] : null;
    final sendMsgRes = await _messageService.sendMessage(
        id: id,
        receiver: receiver,
        needReadReceipt: chatConfig.isShowGroupReadingStatus &&
            convType == ConvType.group &&
            ((chatConfig.groupReadReceiptPermissionList != null &&
                    chatConfig.groupReadReceiptPermissionList!
                        .contains(groupType)) ||
                (chatConfig.groupReadReceiptPermisionList != null &&
                    chatConfig.groupReadReceiptPermisionList!
                        .contains(oldGroupType))),
        groupID: groupID,
        offlinePushInfo: offlinePushInfo,
        onlineUserOnly: onlineUserOnly ?? false,
        cloudCustomData: json.encode({
          "messageFeature": {
            "needTyping": 1,
            "version": 1,
          }
        }));
    if (isEditStatusMessage == false) {
      updateMessage(sendMsgRes, convID, id, convType, groupType, setInputField);
    }

    return sendMsgRes;
  }

  void setMessageList(String conversationID, List<V2TimMessage> messageList,
      {bool needDuration = false}) {
    _messageListMap[conversationID] = messageList;
    if (needDuration) {
      Future.delayed(const Duration(milliseconds: 800), () {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  void setTempMessageList(
      String conversationID, List<V2TimMessage> messageList) {
    _tempMessageListMap[conversationID] = messageList;
    notifyListeners();
  }

  updateMessage(
      V2TimValueCallback<V2TimMessage> sendMsgRes,
      String convID,
      String id,
      ConvType convType,
      GroupReceiptAllowType? groupType,
      ValueChanged<String>? setInputField) {
    List<V2TimMessage> currentHistoryMsgList = _messageListMap[convID] ?? [];
    final V2TimMessage sendMsgResData = sendMsgRes.data as V2TimMessage;
    if ([80001, 80002].contains(sendMsgRes.code) &&
        sendMsgRes.data?.textElem?.text != null &&
        setInputField != null) {
      setInputField(sendMsgRes.data!.textElem!.text ?? "");
    }

    final findIdIndex =
        currentHistoryMsgList.indexWhere((element) => element.id == id);
    final targetIndex = findIdIndex == -1
        ? currentHistoryMsgList
            .indexWhere((element) => element.msgID == sendMsgResData.msgID)
        : findIdIndex;
    if (targetIndex != -1) {
      currentHistoryMsgList[targetIndex] = sendMsgResData;
    } else {
      currentHistoryMsgList = [sendMsgResData, ...currentHistoryMsgList];
    }
    if (loadingMessage[convID] != null && loadingMessage[convID]!.isNotEmpty) {
      loadingMessage[convID]!.removeWhere((element) => element.id == id);
    }
    final oldGroupType =
        groupType != null ? GroupReceptAllowType.values[groupType.index] : null;
    if (chatConfig.isShowGroupReadingStatus &&
        convType == ConvType.group &&
        ((chatConfig.groupReadReceiptPermissionList != null &&
                chatConfig.groupReadReceiptPermissionList!
                    .contains(groupType)) ||
            (chatConfig.groupReadReceiptPermisionList != null &&
                chatConfig.groupReadReceiptPermisionList!
                    .contains(oldGroupType)))) {
      _messageReadReceiptMap[sendMsgRes.data!.msgID!] =
          V2TimMessageReceipt(timestamp: 0, userID: "", readCount: 0);
    }
    _messageListMap[convID] = currentHistoryMsgList;
    notifyListeners();
  }

  List<V2TimMessage>? getMessageList(String conversationID) {
    final list = messageListMap[conversationID]?.reversed.toList() ?? [];
    final List<V2TimMessage> listWithTimestamp = [];
    final interval = chatConfig.timeDividerConfig?.timeInterval ?? 300;
    for (var item in list) {
      {
        if (listWithTimestamp.isEmpty ||
            (listWithTimestamp[listWithTimestamp.length - 1].timestamp !=
                    null &&
                (item.timestamp! -
                        listWithTimestamp[listWithTimestamp.length - 1]
                            .timestamp! >
                    interval))) {
          listWithTimestamp.add(V2TimMessage(
            userID: '',
            isSelf: false,
            elemType: 11,
            msgID: 'time-divider-${item.timestamp}',
            timestamp: item.timestamp,
          ));
        }
        listWithTimestamp.add(V2TimMessage.fromJson(item.toJson()));
      }
    }

    final returnValue = listWithTimestamp.reversed.toList();
    return returnValue;
  }

  HistoryMessagePosition getMessageListPosition(String conversationID) {
    final HistoryMessagePosition? position =
        _historyMessagePositionMap[conversationID];
    if (position == null) {
      _historyMessagePositionMap[conversationID] =
          HistoryMessagePosition.bottom;
      return HistoryMessagePosition.bottom;
    } else {
      return position;
    }
  }

  void setMessageListPosition(
      String conversationID, HistoryMessagePosition position) {
    _historyMessagePositionMap[conversationID] = position;
    notifyListeners();
  }
}
