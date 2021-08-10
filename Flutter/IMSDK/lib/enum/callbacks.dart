import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_info.dart';

typedef VoidCallback = void Function();
typedef ErrorCallback = void Function(int code, String error);
typedef V2TimUserFullInfoCallback = void Function(V2TimUserFullInfo info);
typedef OnRecvC2CTextMessageCallback = void Function(
  String msgID,
  V2TimUserInfo userInfo,
  String text,
);
typedef OnRecvC2CCustomMessageCallback = void Function(
  String msgID,
  V2TimUserInfo sender,
  String customData,
);
typedef OnRecvGroupTextMessageCallback = void Function(
  String msgID,
  String groupID,
  V2TimGroupMemberInfo sender,
  String text,
);

typedef OnRecvGroupCustomMessageCallback = void Function(
  String msgID,
  String groupID,
  V2TimGroupMemberInfo sender,
  String customData,
);
typedef OnMemberEnterCallback = void Function(
  String groupID,
  List<V2TimGroupMemberInfo> memberList,
);
// void 	onMemberEnter (String groupID, List< V2TIMGroupMemberInfo > memberList)
typedef OnMemberLeaveCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo member,
);
// void 	onMemberLeave (String groupID, V2TIMGroupMemberInfo member)
typedef OnMemberInvitedCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
  List<V2TimGroupMemberInfo> memberList,
);
// void 	onMemberInvited (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)
typedef OnMemberKickedCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
  List<V2TimGroupMemberInfo> memberList,
);
// void 	onMemberKicked (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)
typedef OnMemberInfoChangedCallback = void Function(
  String groupID,
  List<V2TimGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList,
);
// void 	onMemberInfoChanged (String groupID, List< V2TIMGroupMemberChangeInfo > v2TIMGroupMemberChangeInfoList)
typedef OnGroupCreatedCallback = void Function(
  String groupID,
);
// void 	onGroupCreated (String groupID)
typedef OnGroupDismissedCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
);
// void 	onGroupDismissed (String groupID, V2TIMGroupMemberInfo opUser)
typedef OnGroupRecycledCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
);
// void 	onGroupRecycled (String groupID, V2TIMGroupMemberInfo opUser)
typedef OnGroupInfoChangedCallback = void Function(
  String groupID,
  List<V2TimGroupChangeInfo> changeInfos,
);
// void 	onGroupInfoChanged (String groupID, List< V2TIMGroupChangeInfo > changeInfos)
typedef OnReceiveJoinApplicationCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo member,
  String opReason,
);
// void 	onReceiveJoinApplication (String groupID, V2TIMGroupMemberInfo member, String opReason)
typedef OnApplicationProcessedCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
  bool isAgreeJoin,
  String opReason,
);
// void 	onApplicationProcessed (String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason)
typedef OnGrantAdministratorCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
  List<V2TimGroupMemberInfo> memberList,
);
// void 	onGrantAdministrator (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)
typedef OnRevokeAdministratorCallback = void Function(
  String groupID,
  V2TimGroupMemberInfo opUser,
  List<V2TimGroupMemberInfo> memberList,
);
// void 	onRevokeAdministrator (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)
typedef OnQuitFromGroupCallback = void Function(
  String groupID,
);
// void 	onQuitFromGroup (String groupID)
typedef OnReceiveRESTCustomDataCallback = void Function(
  String groupID,
  String customData,
);
// void 	onReceiveRESTCustomData (String groupID, byte[] customData)
typedef OnGroupAttributeChangedCallback = void Function(
  String groupID,
  Map<String, String> groupAttributeMap,
);
// void 	onGroupAttributeChanged (String groupID, Map< String, String > groupAttributeMap)
typedef OnRecvNewMessageCallback = void Function(
  V2TimMessage msg,
);
// void 	onRecvNewMessage (V2TIMMessage msg)
typedef OnRecvC2CReadReceiptCallback = void Function(
  List<V2TimMessageReceipt> receiptList,
);
// void 	onRecvC2CReadReceipt (List< V2TIMMessageReceipt > receiptList)
typedef OnRecvMessageRevokedCallback = void Function(
  String msgID,
);
// void 	onRecvMessageRevoked (String msgID)
//
typedef OnFriendApplicationListAddedCallback = void Function(
  List<V2TimFriendApplication> applicationList,
);
// void 	onFriendApplicationListAdded (List< V2TIMFriendApplication > applicationList)
typedef OnFriendApplicationListDeletedCallback = void Function(
  List<String> userIDList,
);
// void 	onFriendApplicationListDeleted (List< String > userIDList)
typedef OnFriendApplicationListReadCallback = void Function();
// void 	onFriendApplicationListRead ()
typedef OnFriendListAddedCallback = void Function(List<V2TimFriendInfo> users);
// void 	onFriendListAdded (List< V2TIMFriendInfo > users)
typedef OnFriendListDeletedCallback = void Function(List<String> userList);
// void 	onFriendListDeleted (List< String > userList)
typedef OnBlackListAddCallback = void Function(List<V2TimFriendInfo> infoList);
// void 	onBlackListAdd (List< V2TIMFriendInfo > infoList)
typedef OnBlackListDeletedCallback = void Function(List<String> userList);
// void 	onBlackListDeleted (List< String > userList)
typedef OnFriendInfoChangedCallback = void Function(
  List<V2TimFriendInfo> infoList,
);
// void 	onFriendInfoChanged (List< V2TIMFriendInfo > infoList)
typedef OnNewConversationCallback = void Function(
  List<V2TimConversation> conversationList,
);
// void 	onNewConversation (List< V2TIMConversation > conversationList)
typedef OnConversationChangedCallback = void Function(
  List<V2TimConversation> conversationList,
);
// void 	onConversationChanged (List< V2TIMConversation > conversationList)
typedef OnReceiveNewInvitationCallback = void Function(
  String inviteID,
  String inviter,
  String groupID,
  List<String> inviteeList,
  String data,
);
// void 	onReceiveNewInvitation (String inviteID, String inviter, String groupID, List< String > inviteeList, String data)
typedef OnInviteeAcceptedCallback = void Function(
  String inviteID,
  String invitee,
  String data,
);
// void 	onInviteeAccepted (String inviteID, String invitee, String data)
typedef OnInviteeRejectedCallback = void Function(
  String inviteID,
  String invitee,
  String data,
);
// void 	onInviteeRejected (String inviteID, String invitee, String data)
typedef OnInvitationCancelledCallback = void Function(
  String inviteID,
  String inviter,
  String data,
);
// void 	onInvitationCancelled (String inviteID, String inviter, String data)
typedef OnInvitationTimeoutCallback = void Function(
  String inviteID,
  List<String> inviteeList,
);
// void 	onInvitationTimeout (String inviteID, List< String > inviteeList)
//
typedef OnSendMessageProgressCallback = void Function(
  V2TimMessage message,
  int progress,
);
