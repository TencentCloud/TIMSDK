// void 	onMemberEnter (String groupID, List< V2TIMGroupMemberInfo > memberList)

// void 	onMemberLeave (String groupID, V2TIMGroupMemberInfo member)

// void 	onMemberInvited (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)

// void 	onMemberKicked (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)

// void 	onMemberInfoChanged (String groupID, List< V2TIMGroupMemberChangeInfo > v2TIMGroupMemberChangeInfoList)

// void 	onGroupCreated (String groupID)

// void 	onGroupDismissed (String groupID, V2TIMGroupMemberInfo opUser)

// void 	onGroupRecycled (String groupID, V2TIMGroupMemberInfo opUser)

// void 	onGroupInfoChanged (String groupID, List< V2TIMGroupChangeInfo > changeInfos)

// void 	onReceiveJoinApplication (String groupID, V2TIMGroupMemberInfo member, String opReason)

// void 	onApplicationProcessed (String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason)

// void 	onGrantAdministrator (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)

// void 	onRevokeAdministrator (String groupID, V2TIMGroupMemberInfo opUser, List< V2TIMGroupMemberInfo > memberList)

// void 	onQuitFromGroup (String groupID)

// void 	onReceiveRESTCustomData (String groupID, byte[] customData)

// void 	onGroupAttributeChanged (String groupID, Map< String, String > groupAttributeMap)

import 'package:tencent_im_sdk_plugin/models/v2_tim_group_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';

import 'callbacks.dart';

class V2TimGroupListener {
  OnMemberEnterCallback onMemberEnter = (
    String groupID,
    List<V2TimGroupMemberInfo> memberList,
  ) {};
  OnMemberLeaveCallback onMemberLeave = (
    String groupID,
    V2TimGroupMemberInfo member,
  ) {};
  OnMemberInvitedCallback onMemberInvited = (
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {};
  OnMemberKickedCallback onMemberKicked = (
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {};
  OnMemberInfoChangedCallback onMemberInfoChanged = (
    String groupID,
    List<V2TimGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList,
  ) {};
  OnGroupCreatedCallback onGroupCreated = (String groupID) {};
  OnGroupDismissedCallback onGroupDismissed = (
    String groupID,
    V2TimGroupMemberInfo opUser,
  ) {};
  OnGroupRecycledCallback onGroupRecycled = (
    String groupID,
    V2TimGroupMemberInfo opUser,
  ) {};
  OnGroupInfoChangedCallback onGroupInfoChanged = (
    String groupID,
    List<V2TimGroupChangeInfo> changeInfos,
  ) {};
  OnReceiveJoinApplicationCallback onReceiveJoinApplication = (
    String groupID,
    V2TimGroupMemberInfo member,
    String opReason,
  ) {};
  OnApplicationProcessedCallback onApplicationProcessed = (
    String groupID,
    V2TimGroupMemberInfo opUser,
    bool isAgreeJoin,
    String opReason,
  ) {};
  OnGrantAdministratorCallback onGrantAdministrator = (
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {};
  OnRevokeAdministratorCallback onRevokeAdministrator = (
    String groupID,
    V2TimGroupMemberInfo opUser,
    List<V2TimGroupMemberInfo> memberList,
  ) {};
  OnQuitFromGroupCallback onQuitFromGroup = (String groupID) {};
  OnReceiveRESTCustomDataCallback onReceiveRESTCustomData = (
    String groupID,
    String customData,
  ) {};
  OnGroupAttributeChangedCallback onGroupAttributeChanged = (
    String groupID,
    Map<String, String> groupAttributeMap,
  ) {};

  V2TimGroupListener({
    OnApplicationProcessedCallback? onApplicationProcessed,
    OnGrantAdministratorCallback? onGrantAdministrator,
    OnGroupAttributeChangedCallback? onGroupAttributeChanged,
    OnGroupCreatedCallback? onGroupCreated,
    OnGroupDismissedCallback? onGroupDismissed,
    OnGroupInfoChangedCallback? onGroupInfoChanged,
    OnGroupRecycledCallback? onGroupRecycled,
    OnMemberEnterCallback? onMemberEnter,
    OnMemberInfoChangedCallback? onMemberInfoChanged,
    OnMemberInvitedCallback? onMemberInvited,
    OnMemberKickedCallback? onMemberKicked,
    OnMemberLeaveCallback? onMemberLeave,
    OnQuitFromGroupCallback? onQuitFromGroup,
    OnReceiveJoinApplicationCallback? onReceiveJoinApplication,
    OnReceiveRESTCustomDataCallback? onReceiveRESTCustomData,
    OnRevokeAdministratorCallback? onRevokeAdministrator,
  }) {
    if (onApplicationProcessed != null) {
      this.onApplicationProcessed = onApplicationProcessed;
    }
    if (onGrantAdministrator != null) {
      this.onGrantAdministrator = onGrantAdministrator;
    }
    if (onGroupAttributeChanged != null) {
      this.onGroupAttributeChanged = onGroupAttributeChanged;
    }
    if (onGroupCreated != null) {
      this.onGroupCreated = onGroupCreated;
    }
    if (onGroupDismissed != null) {
      this.onGroupDismissed = onGroupDismissed;
    }
    if (onGroupInfoChanged != null) {
      this.onGroupInfoChanged = onGroupInfoChanged;
    }
    if (onGroupRecycled != null) {
      this.onGroupRecycled = onGroupRecycled;
    }
    if (onMemberEnter != null) {
      this.onMemberEnter = onMemberEnter;
    }
    if (onMemberInfoChanged != null) {
      this.onMemberInfoChanged = onMemberInfoChanged;
    }
    if (onMemberInvited != null) {
      this.onMemberInvited = onMemberInvited;
    }
    if (onMemberKicked != null) {
      this.onMemberKicked = onMemberKicked;
    }
    if (onMemberLeave != null) {
      this.onMemberLeave = onMemberLeave;
    }
    if (onQuitFromGroup != null) {
      this.onQuitFromGroup = onQuitFromGroup;
    }
    if (onReceiveRESTCustomData != null) {
      this.onReceiveRESTCustomData = onReceiveRESTCustomData;
    }
    if (onReceiveJoinApplication != null) {
      this.onReceiveJoinApplication = onReceiveJoinApplication;
    }
    if (onRevokeAdministrator != null) {
      this.onRevokeAdministrator = onRevokeAdministrator;
    }
  }
}
