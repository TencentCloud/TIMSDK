import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_info.dart';

class Event with ChangeNotifier {
  List<Map<String, dynamic>> events = List.empty(growable: true);
  void addEvents(Map<String, dynamic> event) {
    this.events.add(event);
    notifyListeners();
  }

  void clearEvents() {
    this.events.clear();
    notifyListeners();
  }

  // initListenr
  void onConnectFailed(int code, String error) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onConnectFailed",
          "code": code,
          "error": error,
        },
      ),
    );
  }

  void onConnectSuccess() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onConnectSuccess",
        },
      ),
    );
  }

  void onConnecting() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onConnecting",
        },
      ),
    );
  }

  void onKickedOffline() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onKickedOffline",
        },
      ),
    );
  }

  void onSelfInfoUpdated(V2TimUserFullInfo info) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onSelfInfoUpdated",
          "info": info.toJson(),
        },
      ),
    );
  }

  void onUserSigExpired() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onUserSigExpired",
        },
      ),
    );
  }

  // V2TimSimpleMsgListener
  void onRecvC2CCustomMessage(
    String msgID,
    V2TimUserInfo sender,
    String customData,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvC2CCustomMessage",
          "msgID": msgID,
          "sender": sender.toJson(),
          "customData": customData,
        },
      ),
    );
  }

  void onRecvC2CTextMessage(
    String msgID,
    V2TimUserInfo userInfo,
    String text,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvC2CTextMessage",
          "msgID": msgID,
          "userInfo": userInfo.toJson(),
          "text": text,
        },
      ),
    );
  }

  void onRecvGroupCustomMessage(
    String msgID,
    String groupID,
    V2TimGroupMemberInfo sender,
    String customData,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvGroupCustomMessage",
          "msgID": msgID,
          "groupID": groupID,
          "sender": sender.toJson(),
          "customData": customData,
        },
      ),
    );
  }

  void onRecvGroupTextMessage(
    String msgID,
    String groupID,
    V2TimGroupMemberInfo sender,
    String text,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvGroupTextMessage",
          "msgID": msgID,
          "groupID": groupID,
          "sender": sender.toJson(),
          "text": text,
        },
      ),
    );
  }

// V2TimGroupListener
  void onApplicationProcessed(
    String groupID,
    V2TimGroupMemberInfo opUser,
    bool isAgreeJoin,
    String opReason,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onApplicationProcessed",
          "groupID": groupID,
          "opUser": opUser.toJson(),
          "isAgreeJoin": isAgreeJoin,
          "opReason": opReason,
        },
      ),
    );
  }

  void onGrantAdministrator(
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    memberList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onGrantAdministrator",
          "groupID": groupID,
          "opUser": opUser.toJson(),
          "memberList": ml,
        },
      ),
    );
  }

  void onGroupAttributeChanged(
    String groupID,
    Map<String, String> groupAttributeMap,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onApplicationProcessed",
          "groupID": groupID,
          "groupAttributeMap": groupAttributeMap,
        },
      ),
    );
  }

  void onGroupCreated(groupID) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onGroupCreated",
          "groupID": groupID,
        },
      ),
    );
  }

  void onGroupDismissed(
    String groupID,
    V2TimGroupMemberInfo opUser,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onGroupDismissed",
          "groupID": groupID,
          "opUser": opUser.toJson(),
        },
      ),
    );
  }

  void onGroupInfoChanged(
    String groupID,
    List<V2TimGroupChangeInfo> changeInfos,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    changeInfos.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onGroupInfoChanged",
          "groupID": groupID,
          "changeInfos": ml,
        },
      ),
    );
  }

  void onGroupRecycled(
    String groupID,
    V2TimGroupMemberInfo opUser,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onGroupRecycled",
          "groupID": groupID,
          "opUser": opUser.toJson(),
        },
      ),
    );
  }

  void onMemberEnter(
    String groupID,
    List<V2TimGroupMemberInfo> memberList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    memberList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onMemberEnter",
          "groupID": groupID,
          "memberList": ml,
        },
      ),
    );
  }

  void onMemberInfoChanged(
    String groupID,
    List<V2TimGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    v2TIMGroupMemberChangeInfoList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onMemberInfoChanged",
          "groupID": groupID,
          "v2TIMGroupMemberChangeInfoList": ml,
        },
      ),
    );
  }

  void onMemberInvited(
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    memberList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onMemberInvited",
          "groupID": groupID,
          "opUser": opUser.toJson(),
          "memberList": ml,
        },
      ),
    );
  }

  void onMemberKicked(
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    memberList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onMemberKicked",
          "groupID": groupID,
          "opUser": opUser.toJson(),
          "memberList": ml,
        },
      ),
    );
  }

  void onMemberLeave(
    String groupID,
    V2TimGroupMemberInfo member,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onMemberLeave",
          "groupID": groupID,
          "member": member.toJson(),
        },
      ),
    );
  }

  void onQuitFromGroup(String groupID) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onQuitFromGroup",
          "groupID": groupID,
        },
      ),
    );
  }

  void onReceiveJoinApplication(
    String groupID,
    V2TimGroupMemberInfo member,
    String opReason,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onReceiveJoinApplication",
          "groupID": groupID,
          "member": member.toJson(),
          "opReason": opReason
        },
      ),
    );
  }

  void onReceiveRESTCustomData(
    String groupID,
    String customData,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onReceiveRESTCustomData",
          "groupID": groupID,
          "customData": customData
        },
      ),
    );
  }

  void onRevokeAdministrator(
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    memberList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRevokeAdministrator",
          "groupID": groupID,
          "opUser": opUser.toJson(),
          "memberList": ml,
        },
      ),
    );
  }

  // V2TimAdvancedMsgListener
  void onRecvC2CReadReceipt(
    List<V2TimMessageReceipt> receiptList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    receiptList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvC2CReadReceipt",
          "receiptList": ml,
        },
      ),
    );
  }

  void onRecvMessageRevoked(String msgID) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvMessageRevoked",
          "msgID": msgID,
        },
      ),
    );
  }

  void onRecvNewMessage(V2TimMessage msg) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onRecvNewMessage",
          "msg": msg.toJson(),
        },
      ),
    );
  }

  void onSendMessageProgress(
    V2TimMessage message,
    int progress,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onSendMessageProgress",
          "message": message.toJson(),
          "progress": progress,
        },
      ),
    );
  }

// 信令
  void onInvitationCancelled(
    String inviteID,
    String inviter,
    String data,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onInvitationCancelled",
          "inviteID": inviteID,
          "inviter": inviter,
          "data": data,
        },
      ),
    );
  }

  void onInvitationTimeout(String inviteID, List<String> inviteeList) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onInvitationTimeout",
          "inviteID": inviteID,
          "inviteeList": inviteeList,
        },
      ),
    );
  }

  void onInviteeAccepted(
    String inviteID,
    String invitee,
    String data,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onInviteeAccepted",
          "inviteID": inviteID,
          "invitee": invitee,
          "data": data,
        },
      ),
    );
  }

  void onInviteeRejected(
    String inviteID,
    String invitee,
    String data,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onInviteeRejected",
          "inviteID": inviteID,
          "invitee": invitee,
          "data": data,
        },
      ),
    );
  }

  void onReceiveNewInvitation(
    String inviteID,
    String inviter,
    String groupID,
    List<String> inviteeList,
    String data,
  ) {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onReceiveNewInvitation",
          "inviteID": inviteID,
          "groupID": groupID,
          "inviter": inviter,
          "inviteeList": inviteeList,
          "data": data,
        },
      ),
    );
  }

  // 会话
  void onConversationChanged(
    List<V2TimConversation> conversationList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    conversationList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onConversationChanged",
          "conversationList": ml,
        },
      ),
    );
  }

  void onNewConversation(
    List<V2TimConversation> conversationList,
  ) {
    List<Map<String, dynamic>> ml = List.empty(growable: true);
    conversationList.forEach((element) {
      ml.add(element.toJson());
    });
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onNewConversation",
          "conversationList": ml,
        },
      ),
    );
  }

  void onSyncServerFailed() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onSyncServerFailed",
        },
      ),
    );
  }

  void onSyncServerFinish() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onSyncServerFinish",
        },
      ),
    );
  }

  void onSyncServerStart() {
    this.addEvents(
      Map<String, dynamic>.from(
        {
          "type": "onSyncServerStart",
        },
      ),
    );
  }
}
