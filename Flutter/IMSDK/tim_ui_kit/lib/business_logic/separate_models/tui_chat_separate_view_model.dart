import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tim_ui_kit/business_logic/separate_models/tui_chat_model_tools.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/message/message_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';
import 'package:uuid/uuid.dart';

class TUIChatSeparateViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final MessageService _messageService = serviceLocator<MessageService>();
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  final TUIChatGlobalModel globalModel = serviceLocator<TUIChatGlobalModel>();
  final TUIChatModelTools tools = serviceLocator<TUIChatModelTools>();
  final _uuid = const Uuid();

  ChatLifeCycle? lifeCycle;
  int _totalUnreadCount = 0;
  bool _isMultiSelect = false;
  bool _isInit = false;
  String conversationID = "";
  ConvType? conversationType;
  bool haveMoreData = false;
  String _currentSelectedMsgId = "";
  String _editRevokedMsg = "";
  GroupReceiptAllowType? _groupType;
  List<V2TimMessage> _multiSelectedMessageList = [];
  V2TimMessage? _repliedMessage;
  String _jumpMsgID = "";
  bool _isGroupExist = true;
  bool _isNotAMember = false;
  bool showC2cMessageEditStatus = true;
  TIMUIKitChatConfig chatConfig = const TIMUIKitChatConfig();
  ValueChanged<String>? setInputField;
  String Function(V2TimMessage message)? abstractMessageBuilder;
  Function(String userID)? onTapAvatar;
  V2TimGroupMemberFullInfo? _currentChatUserInfo;
  V2TimGroupInfo? _groupInfo;
  String groupMemberListSeq = "0";
  List<V2TimGroupMemberFullInfo?>? groupMemberList = [];
  V2TimGroupInfo? get groupInfo => _groupInfo;

  set groupInfo(V2TimGroupInfo? value) {
    _groupInfo = value;
    notifyListeners();
  }

  int get totalUnreadCount => _totalUnreadCount;

  set totalUnreadCount(int value) {
    _totalUnreadCount = value;
    notifyListeners();
  }

  bool get isMultiSelect => _isMultiSelect;

  set isMultiSelect(bool value) {
    _isMultiSelect = value;
    notifyListeners();
  }

  String get currentSelectedMsgId => _currentSelectedMsgId;

  set currentSelectedMsgId(String value) {
    _currentSelectedMsgId = value;
    notifyListeners();
  }

  String get editRevokedMsg => _editRevokedMsg;

  set editRevokedMsg(String value) {
    _editRevokedMsg = value;
    notifyListeners();
  }

  GroupReceiptAllowType? get groupType => _groupType;

  set groupType(GroupReceiptAllowType? value) {
    _groupType = value;
    notifyListeners();
  }

  List<V2TimMessage> get multiSelectedMessageList => _multiSelectedMessageList;

  set multiSelectedMessageList(List<V2TimMessage> value) {
    _multiSelectedMessageList = value;
    notifyListeners();
  }

  V2TimMessage? get repliedMessage => _repliedMessage;

  set repliedMessage(V2TimMessage? value) {
    _repliedMessage = value;
    notifyListeners();
  }

  String get jumpMsgID => _jumpMsgID;

  set jumpMsgID(String value) {
    _jumpMsgID = value;
    notifyListeners();
  }

  bool get isGroupExist => _isGroupExist;

  set isGroupExist(bool value) {
    _isGroupExist = value;
    notifyListeners();
  }

  bool get isNotAMember => _isNotAMember;

  set isNotAMember(bool value) {
    _isNotAMember = value;
    notifyListeners();
  }

  V2TimGroupMemberFullInfo? get currentChatUserInfo => _currentChatUserInfo;

  set currentChatUserInfo(V2TimGroupMemberFullInfo? value) {
    _currentChatUserInfo = value;
    notifyListeners();
  }

  setLoadingMessageMap(String conversationID, V2TimMessage messageInfo) {
    if (PlatformUtils().isWeb) {
      if (globalModel.loadingMessage[conversationID] != null &&
          globalModel.loadingMessage[conversationID]!.isNotEmpty) {
        globalModel.loadingMessage[conversationID]!.add(messageInfo);
      } else {
        globalModel.loadingMessage[conversationID] = <V2TimMessage>[
          messageInfo
        ];
      }
    }
  }

  void initForEachConversation(ConvType convType, String convID,
      ValueChanged<String>? onChangeInputField,
      {String? groupID}) async {
    if (_isInit) {
      return;
    }
    setInputField = onChangeInputField;
    conversationType = convType;
    conversationID = convID;
    if (conversationType == ConvType.group) {
      globalModel.refreshGroupApplicationList();
      getGroupInfo(groupID ?? convID);
      loadGroupMemberList(groupID: groupID ?? convID);
    }
    if (conversationType == ConvType.c2c) {
      final List<V2TimFriendInfoResult>? friendRes =
          await _friendshipServices.getFriendsInfo(userIDList: [convID]);
      if (friendRes != null && friendRes.isNotEmpty) {
        final V2TimFriendInfoResult friendInfoResult = friendRes[0];
        currentChatUserInfo = V2TimGroupMemberFullInfo(
            userID: convID,
            faceUrl: friendInfoResult.friendInfo?.userProfile?.faceUrl,
            nickName: friendInfoResult.friendInfo?.userProfile?.nickName,
            friendRemark: friendInfoResult.friendInfo?.friendRemark);
      } else {
        final List<V2TimUserFullInfo>? userRes =
            await _friendshipServices.getUsersInfo(userIDList: [convID]);
        if (userRes != null && userRes.isNotEmpty) {
          final V2TimUserFullInfo userFullInfo = userRes[0];
          currentChatUserInfo = V2TimGroupMemberFullInfo(
            userID: convID,
            faceUrl: userFullInfo.faceUrl,
            nickName: userFullInfo.nickName,
          );
        }
      }
    }
    markMessageAsRead();
    globalModel.lifeCycle = lifeCycle;
    globalModel.setCurrentConversation(
        CurrentConversation(conversationID, conversationType ?? ConvType.c2c));
    globalModel.setTempMessageList(conversationID, []);
    globalModel.setMessageListPosition(
        conversationID, HistoryMessagePosition.bottom);
    globalModel.setChatConfig(chatConfig);
    _isInit = true;
  }

  Future<bool> loadData({
    HistoryMsgGetTypeEnum getType =
        HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    haveMoreData = false;
    final currentHistoryMsgList = globalModel.messageListMap[conversationID];
    final response = await _messageService.getHistoryMessageList(
        count: count,
        getType: getType,
        userID: conversationType == ConvType.c2c ? conversationID : null,
        groupID: conversationType == ConvType.group ? conversationID : null,
        lastMsgID: lastMsgID,
        lastMsgSeq: lastMsgSeq);
    if (lastMsgID != null && currentHistoryMsgList != null) {
      final newList = [...currentHistoryMsgList, ...response];
      final List<V2TimMessage> msgList =
          await lifeCycle?.didGetHistoricalMessageList(newList) ?? newList;
      globalModel.setMessageList(conversationID, msgList, needDuration: false);
    } else {
      List<V2TimMessage> messageList =
          await lifeCycle?.didGetHistoricalMessageList(response) ?? response;
      if (globalModel.loadingMessage[conversationID] != null) {
        if (globalModel.loadingMessage[conversationID]!.isNotEmpty) {
          messageList = [
            ...?globalModel.loadingMessage[conversationID],
            ...messageList
          ];
        } else {
          globalModel.loadingMessage.remove(conversationID);
        }
      }
      globalModel.setMessageList(conversationID, messageList,
          needDuration: false);
      // The messages in first screen
    }
    if (response.isEmpty ||
        (!PlatformUtils().isWeb && response.length < count) ||
        (PlatformUtils().isWeb && response.length < min(count, 20))) {
      haveMoreData = false;
    } else {
      haveMoreData = true;
    }
    // notifyListeners();
    if (chatConfig.isShowGroupReadingStatus &&
        conversationType == ConvType.group &&
        response.isNotEmpty) {
      _getMsgReadReceipt(response);
    }
    if (chatConfig.isReportGroupReadingStatus &&
        conversationType == ConvType.group &&
        response.isNotEmpty) {
      _setMsgReadReceipt(response);
    }
    return haveMoreData;
  }

  Future<bool> loadDataFromController({int? count}) {
    return loadData(
      count: count ?? HistoryMessageDartConstant.getCount, //20
    );
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts(
      List<String> messageIDList) {
    return _messageService.getMessageReadReceipts(messageIDList: messageIDList);
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
            globalModel.messageReadReceiptMap[item.msgID!] = item;
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

  sendMessageReadReceipts(List<String> messageIDList) async {
    final res = await _messageService.sendMessageReadReceipts(
        messageIDList: messageIDList);
    return res;
  }

  markMessageAsRead() async {
    globalModel.unreadCountForConversation = 0;
    if (conversationType == ConvType.c2c) {
      return _messageService.markC2CMessageAsRead(userID: conversationID);
    }

    final res =
        await _messageService.markGroupMessageAsRead(groupID: conversationID);
    if (res.code == 10015) {
      isGroupExist = false;
    }
  }

  loadGroupInfo(String groupID) async {
    final groupInfo =
        await _groupServices.getGroupsInfo(groupIDList: [groupID]);
    if (groupInfo != null) {
      final groupRes = groupInfo.first;
      if (groupRes.resultCode == 0) {
        _groupInfo = groupRes.groupInfo;
      }
    }
    notifyListeners();
  }

  Future<void> loadGroupMemberList(
      {required String groupID, int count = 100, String? seq}) async {
    final String? nextSeq = await _loadGroupMemberListFunction(
        groupID: groupID, seq: seq, count: count);
    if (nextSeq != null && nextSeq != "0" && nextSeq != "") {
      return await loadGroupMemberList(
          groupID: groupID, count: count, seq: nextSeq);
    } else {
      notifyListeners();
    }
  }

  Future<String?> _loadGroupMemberListFunction(
      {required String groupID, int count = 100, String? seq}) async {
    if (seq == null || seq == "" || seq == "0") {
      groupMemberList?.clear();
    }
    final res = await _groupServices.getGroupMemberList(
        groupID: groupID,
        filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
        count: count,
        nextSeq: seq ?? groupMemberListSeq);
    final groupMemberListRes = res.data;
    if (res.code == 0 && groupMemberListRes != null) {
      final groupMemberListTemp = groupMemberListRes.memberInfoList ?? [];
      groupMemberList = [...?groupMemberList, ...groupMemberListTemp];
      groupMemberListSeq = groupMemberListRes.nextSeq ?? "0";
    } else if (res.code == 10010) {
      isGroupExist = false;
    } else if (res.code == 10007) {
      isNotAMember = true;
    }
    return groupMemberListRes?.nextSeq;
  }

  getGroupInfo(String groupID) async {
    final res = await _groupServices.getGroupsInfo(groupIDList: [groupID]);
    if (res != null) {
      final groupRes = res.first;
      if (groupRes.resultCode == 0) {
        const groupTypeMap = {
          "Meeting": GroupReceiptAllowType.meeting,
          "Public": GroupReceiptAllowType.public,
          "Work": GroupReceiptAllowType.work
        };
        _groupInfo = groupRes.groupInfo;
        _groupType = groupTypeMap[groupRes.groupInfo?.groupType];
      }
    }
  }

  Future<void> updateMessageFromController({required String msgID}) async {
    V2TimMessage? newMessage = await tools.getExistingMessageByID(
        msgID: msgID,
        conversationType: conversationType ?? ConvType.c2c,
        conversationID: conversationID);
    if (newMessage != null) {
      globalModel.onMessageModified(newMessage, conversationID);
    } else {
      loadData(
        count: HistoryMessageDartConstant.getCount,
      );
    }
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>?> modifyMessage(
      {required V2TimMessage message}) async {
    return _messageService.modifyMessage(message: message);
  }

  Future<V2TimValueCallback<V2TimMessage>> _sendMessage({
    required String id,
    required String convID,
    required ConvType convType,
    V2TimMessage? messageInfo,
    OfflinePushInfo? offlinePushInfo,
    bool? onlineUserOnly = false,
    bool? isEditStatusMessage = false,
  }) async {
    String receiver = convType == ConvType.c2c ? convID : '';
    String groupID = convType == ConvType.group ? convID : '';
    final oldGroupType = _groupType != null
        ? GroupReceptAllowType.values[_groupType!.index]
        : null;
    if (messageInfo != null) {
      setLoadingMessageMap(convID, messageInfo);
    }
    final sendMsgRes = await _messageService.sendMessage(
      id: id,
      receiver: receiver,
      needReadReceipt: chatConfig.isShowGroupReadingStatus &&
          convType == ConvType.group &&
          ((chatConfig.groupReadReceiptPermissionList != null &&
                  chatConfig.groupReadReceiptPermissionList!
                      .contains(_groupType)) ||
              (chatConfig.groupReadReceiptPermisionList != null &&
                  chatConfig.groupReadReceiptPermisionList!
                      .contains(oldGroupType))),
      groupID: groupID,
      offlinePushInfo: offlinePushInfo,
      onlineUserOnly: onlineUserOnly ?? false,
      cloudCustomData: showC2cMessageEditStatus == true
          ? json.encode({
              "messageFeature": {
                "needTyping": 1,
                "version": 1,
              }
            })
          : "",
    );
    if (isEditStatusMessage == false) {
      globalModel.updateMessage(
          sendMsgRes, convID, id, convType, groupType, setInputField);
    }

    return sendMsgRes;
  }

  List<V2TimMessage> getOriginMessageList() {
    return globalModel.messageListMap[conversationID] ?? [];
  }

  List<V2TimMessage> getTempMessageList() {
    return globalModel.tempMessageListMap[conversationID] ?? [];
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = textATMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, textATMessageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textATMessageInfo.id as String,
          convType: ConvType.group,
          offlinePushInfo: tools.buildMessagePushInfo(
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = textATMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, textATMessageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textATMessageInfo.id as String,
          convType: convType,
          offlinePushInfo: tools.buildMessagePushInfo(
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, textMessageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);
      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textMessageInfo.id as String,
          convType: convType,
          messageInfo: lifeCycleMsg ?? messageInfoWithSender,
          offlinePushInfo: tools.buildMessagePushInfo(
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = soundMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, soundMessageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: soundMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: tools.buildMessagePushInfo(
            soundMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  String _getAbstractMessage(V2TimMessage message) {
    final elemType = message.elemType;
    switch (elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        return "[表情消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return "[自定义消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return "[文件消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return "[群消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return "[图片消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return "[位置消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
        return "[合并消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_NONE:
        return "[没有元素]";
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return "[语音消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return "[文本消息]";
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return "[视频消息]";
      default:
        return "";
    }
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendReplyMessage(
      {required String text,
      required String convID,
      required ConvType convType}) async {
    if (text.isEmpty) {
      return null;
    }
    if (_repliedMessage != null) {
      final V2TimMsgCreateInfoResult? textMessageInfo =
          await _messageService.createTextMessage(text: text);
      final V2TimMessage? messageInfo = textMessageInfo!.messageInfo;
      final receiver = convType == ConvType.c2c ? convID : '';
      final groupID = convType == ConvType.group ? convID : '';
      final oldGroupType = _groupType != null
          ? GroupReceptAllowType.values[_groupType!.index]
          : null;
      if (messageInfo != null) {
        V2TimMessage messageInfoWithSender =
            tools.setUserInfoForMessage(messageInfo, messageInfo.id!);
        final hasNickName = _repliedMessage?.nickName != null &&
            _repliedMessage?.nickName != "";
        final cloudCustomData = {
          "messageReply": {
            "messageID": _repliedMessage!.msgID,
            "messageAbstract": _getAbstractMessage(_repliedMessage!),
            "messageSender": hasNickName
                ? _repliedMessage!.nickName
                : _repliedMessage?.sender,
            "messageType": _repliedMessage?.elemType,
            "version": 1
          }
        };
        messageInfoWithSender.cloudCustomData = json.encode(cloudCustomData);
        V2TimMessage? lifeCycleMsg;
        if (lifeCycle?.messageWillSend != null) {
          lifeCycleMsg =
              await lifeCycle?.messageWillSend(messageInfoWithSender);
          if (lifeCycleMsg == null) {
            return null;
          }
        }
        List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
        currentHistoryMsgList = [
          lifeCycleMsg ?? messageInfoWithSender,
          ...currentHistoryMsgList
        ];
        globalModel.setMessageList(conversationID, currentHistoryMsgList);

        final sendMsgRes = await _messageService.sendReplyMessage(
            id: textMessageInfo.id as String,
            replyMessage: _repliedMessage!,
            offlinePushInfo: tools.buildMessagePushInfo(
                messageInfoWithSender, convID, convType),
            needReadReceipt: chatConfig.isShowGroupReadingStatus &&
                convType == ConvType.group &&
                ((chatConfig.groupReadReceiptPermissionList != null &&
                        chatConfig.groupReadReceiptPermissionList!
                            .contains(_groupType)) ||
                    (chatConfig.groupReadReceiptPermisionList != null &&
                        chatConfig.groupReadReceiptPermisionList!
                            .contains(oldGroupType))),
            groupID: groupID,
            receiver: receiver);
        _repliedMessage = null;
        notifyListeners();
        globalModel.updateMessage(sendMsgRes, convID,
            messageInfoWithSender.id ?? "", convType, groupType, setInputField);
        return sendMsgRes;
      }
    }
    return null;
  }

  double getFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<String> getTempPath() async {
    final id = _uuid.v4();
    return getTemporaryDirectory().then((appDocDir) {
      String filePath = appDocDir.path + id + ".jpeg";
      return filePath;
    });
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendImageMessage(
      {String? imagePath,
      required String convID,
      dynamic inputElement,
      required ConvType convType}) async {
    String? image;
    if ((PlatformUtils().isAndroid || PlatformUtils().isIOS) &&
        imagePath != null &&
        imagePath.isNotEmpty) {
      try {
        final size = getFileSize(File(imagePath));
        final format =
            imagePath.split(".")[imagePath.split(".").length - 1].toLowerCase();
        if (size > 20 ||
            (format != "jpg" && format != "png" && format != "gif")) {
          final target = await getTempPath();
          final result = await FlutterImageCompress.compressAndGetFile(
              imagePath, target,
              format: CompressFormat.jpeg, quality: 85);
          image = result?.path;
        }
      } catch (e) {
        print(e);
      }
    }
    final imageMessageInfo = await _messageService.createImageMessage(
        imagePath: image ?? imagePath, inputElement: inputElement);
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = imageMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, imageMessageInfo.id);

      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
        convID: convID,
        messageInfo: lifeCycleMsg ?? messageInfoWithSender,
        id: imageMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: tools.buildMessagePushInfo(
            imageMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendVideoMessage(
      {String? videoPath,
      int? duration,
      String? snapshotPath,
      required String convID,
      required ConvType convType,
      dynamic inputElement}) async {
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final videoMessageInfo = await _messageService.createVideoMessage(
        videoPath: videoPath,
        type: 'mp4',
        duration: duration,
        inputElement: inputElement,
        snapshotPath: snapshotPath);
    final messageInfo = videoMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, videoMessageInfo.id);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
        convID: convID,
        messageInfo: lifeCycleMsg ?? messageInfoWithSender,
        id: videoMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: tools.buildMessagePushInfo(
            videoMessageInfo.messageInfo!, convID, convType),
      );
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> sendFileMessage(
      {String? filePath,
      String? fileName,
      int? size,
      dynamic inputElement,
      required String convID,
      required ConvType convType}) async {
    final fileMessageInfo = await _messageService.createFileMessage(
        inputElement: inputElement,
        fileName: fileName ?? filePath?.split('/').last ?? "",
        filePath: filePath);
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = fileMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, fileMessageInfo.id);
      messageInfoWithSender.fileElem!.fileSize = size;
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
        convID: convID,
        messageInfo: lifeCycleMsg ?? messageInfoWithSender,
        id: fileMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: tools.buildMessagePushInfo(
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final locationMessageInfo = await _messageService.createLocationMessage(
        desc: desc, longitude: longitude, latitude: latitude);
    final messageInfo = locationMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, locationMessageInfo.id);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
        convID: convID,
        id: locationMessageInfo.id as String,
        convType: convType,
        offlinePushInfo: tools.buildMessagePushInfo(
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
              tools.setUserInfoForMessage(messageInfo, forwardMessageInfo.id);
          V2TimMessage? lifeCycleMsg;
          if (lifeCycle?.messageWillSend != null) {
            lifeCycleMsg =
                await lifeCycle?.messageWillSend(messageInfoWithSender);
            if (lifeCycleMsg == null) {
              return null;
            }
          }
          _sendMessage(
            id: forwardMessageInfo.id!,
            convID: convID,
            convType: convType == 1 ? ConvType.c2c : ConvType.group,
            offlinePushInfo: tools.buildMessagePushInfo(
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
          compatibleText: TIM_t("该版本不支持此消息"));
      final messageInfo = mergerMessageInfo!.messageInfo;
      if (messageInfo != null) {
        final messageInfoWithSender =
            tools.setUserInfoForMessage(messageInfo, mergerMessageInfo.id);

        V2TimMessage? lifeCycleMsg;
        if (lifeCycle?.messageWillSend != null) {
          lifeCycleMsg =
              await lifeCycle?.messageWillSend(messageInfoWithSender);
          if (lifeCycleMsg == null) {
            return null;
          }
        }
        return _sendMessage(
          id: mergerMessageInfo.id!,
          convID: convID,
          convType: convType == 1 ? ConvType.c2c : ConvType.group,
          offlinePushInfo: tools.buildMessagePushInfo(
              mergerMessageInfo.messageInfo!,
              convID,
              convType == 1 ? ConvType.c2c : ConvType.group),
        );
      }
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?> reSendMessage(
      {required String msgID,
      required String convID,
      bool? onlineUserOnly}) async {
    final res = await _messageService.reSendMessage(
        msgID: msgID, onlineUserOnly: onlineUserOnly ?? false);
    final messageInfo = res.data;
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    // final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, messageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(convID, currentHistoryMsgList);
    }
    return res;
  }

  // 注意重发消息需要先删除之前发送失败的图
  Future<V2TimValueCallback<V2TimMessage>?> reSendFailMessage(
      {required V2TimMessage message,
      required String convID,
      required ConvType convType}) async {
    await deleteMsg(message.msgID ?? "",
        id: message.id, webMessageInstance: message.messageFromWeb);
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
    if (messageType == MessageElemType.V2TIM_ELEM_TYPE_CUSTOM) {
      String data = message.customElem?.data ?? "";
      res = await sendCustomMessage(
          convID: convID, convType: convType, data: data);
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
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    final messageInfo = textMessageInfo!.messageInfo;
    if (messageInfo != null) {
      final messageInfoWithSender =
          tools.setUserInfoForMessage(messageInfo, textMessageInfo.id!);
      V2TimMessage? lifeCycleMsg;
      if (lifeCycle?.messageWillSend != null) {
        lifeCycleMsg = await lifeCycle?.messageWillSend(messageInfoWithSender);
        if (lifeCycleMsg == null) {
          return null;
        }
      }
      currentHistoryMsgList = [
        lifeCycleMsg ?? messageInfoWithSender,
        ...currentHistoryMsgList
      ];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);

      notifyListeners();
      return _sendMessage(
          convID: convID,
          id: textMessageInfo.id as String,
          convType: convType,
          offlinePushInfo: tools.buildMessagePushInfo(
              textMessageInfo.messageInfo!, convID, convType));
    }
    return null;
  }

  Future<V2TimValueCallback<V2TimMessage>?>? sendMessageFromController({
    required V2TimMessage? messageInfo,

    /// Offline push info
    OfflinePushInfo? offlinePushInfo,
  }) {
    List<V2TimMessage> currentHistoryMsgList = getOriginMessageList();
    if (messageInfo != null) {
      final messageInfoWithSender = messageInfo.sender == null
          ? tools.setUserInfoForMessage(messageInfo, messageInfo.id!)
          : messageInfo;
      currentHistoryMsgList = [messageInfoWithSender, ...currentHistoryMsgList];
      globalModel.setMessageList(conversationID, currentHistoryMsgList);
      return _sendMessage(
        convID: conversationID,
        id: messageInfo.id as String,
        convType: conversationType ?? ConvType.c2c,
        offlinePushInfo: offlinePushInfo ??
            tools.buildMessagePushInfo(
                messageInfo, conversationID, conversationType ?? ConvType.c2c),
      );
    }
    return null;
  }

  deleteMsg(String msgID, {String? id, Object? webMessageInstance}) async {
    if (lifeCycle?.shouldDeleteMessage != null &&
        await lifeCycle!.shouldDeleteMessage(msgID) == false) {
      return;
    }
    final messageList = getOriginMessageList();
    final res = await _messageService.deleteMessageFromLocalStorage(
        msgID: msgID, webMessageInstance: webMessageInstance);
    if (res.code == 0) {
      messageList.removeWhere((element) {
        return element.msgID == msgID || (id != null && element.id == id);
      });
    }
    globalModel.setMessageList(conversationID, messageList);
  }

  clearHistory() async {
    if (lifeCycle?.shouldClearHistoricalMessageList != null &&
        await lifeCycle!.shouldClearHistoricalMessageList(conversationID) ==
            false) {
      return;
    }
    globalModel.setMessageList(conversationID, []);
  }

  Future<V2TimCallback> revokeMsg(String msgID,
      [Object? webMessageInstance]) async {
    final res = await _messageService.revokeMessage(
        msgID: msgID, webMessageInstance: webMessageInstance);

    if (res.code == 0) {
      globalModel.onMessageRevoked(msgID, conversationID);
    }
    return res;
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
    List<V2TimMessage> messageList = getOriginMessageList();
    final msgIDs = _multiSelectedMessageList
        .map((e) => e.msgID ?? "")
        .where((element) => element != "")
        .toList();
    final webMessageInstanceList = _multiSelectedMessageList
        .map((e) => e.messageFromWeb)
        .where((element) => element != null)
        .toList();

    final res = await _messageService.deleteMessages(
        msgIDs: msgIDs, webMessageInstanceList: webMessageInstanceList);
    if (res.code == 0) {
      for (var msgID in msgIDs) {
        messageList.removeWhere((element) => element.msgID == msgID);
      }
      globalModel.setMessageList(conversationID, messageList);
    }
  }

  updateMultiSelectStatus(bool isSelect) {
    _isMultiSelect = isSelect;
    if (!isSelect) {
      _multiSelectedMessageList.clear();
    }
    notifyListeners();
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList(String messageID,
          GetGroupMessageReadMemberListFilter fileter, int nextSeq) async {
    final res = await _messageService.getGroupMessageReadMemberList(
        nextSeq: nextSeq, messageID: messageID, filter: fileter);
    return res;
  }

  Future<List<V2TimMessage>?> downloadMergerMessage(String msgID) async {
    await _messageService.getHistoryMessageList(
      count: 100,
      getType: HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG,
      userID: conversationType == ConvType.c2c ? conversationID : null,
      groupID: conversationType == ConvType.group ? conversationID : null,
    );
    return _messageService.downloadMergerMessage(msgID: msgID);
  }

  Future<V2TimMessage?> findMessage(String msgID) async {
    List<V2TimMessage> messageList = getOriginMessageList();
    final repliedMessage =
        messageList.where((element) => element.msgID == msgID).toList();
    if (repliedMessage.isNotEmpty) {
      return repliedMessage.first;
    }
    final message = await _messageService.findMessages(messageIDList: [msgID]);
    if (message != null && message.isNotEmpty) {
      return message.first;
    }
    return null;
  }

  showLatestUnread() {
    List<V2TimMessage> currentMsgList = getOriginMessageList();
    currentMsgList = [
      ...?globalModel.tempMessageListMap[conversationID],
      ...currentMsgList
    ];
    markMessageAsRead();
    globalModel.setMessageListPosition(
        conversationID, HistoryMessagePosition.bottom);
    globalModel.setTempMessageList(conversationID, []);
    globalModel.setMessageList(conversationID, currentMsgList);
  }

  @override
  void dispose() {
    globalModel.clearCurrentConversation();
    _isInit = false;
    super.dispose();
  }
}
