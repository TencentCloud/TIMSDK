//
//  SignalingListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/24.
//
import Foundation
import ImSDK_Plus

class SignalingListener: NSObject, V2TIMSignalingListener {
	/*
	 * SignalingActionType_Invite           = 1,  // 邀请方发起邀请
	 * SignalingActionType_Cancel_Invite    = 2,  // 邀请方取消邀请
	 * SignalingActionType_Accept_Invite    = 3,  // 被邀请方接受邀请
	 * SignalingActionType_Reject_Invite    = 4,  // 被邀请方拒绝邀请
	 * SignalingActionType_Invite_Timeout   = 5,  // 邀请超时
	*/
    let listenerUuid:String;
    init(listenerUid: String) {
        listenerUuid = listenerUid;
    }
	public func onReceiveNewInvitation(_ inviteID: String!, inviter: String!, groupID: String!, inviteeList: [String]!, data: String?) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onReceiveNewInvitation, method: "signalingListener", data: [
			"inviteID": inviteID!,
			"data": data ?? "",
			"groupID": groupID as Any,
			"inviter": inviter as Any,
			"inviteeList": inviteeList!
		],listenerUuid: listenerUuid)
	}
	/// 被邀请者接受邀请
	public func onInviteeAccepted(_ inviteID: String!, invitee: String!, data: String?) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onInviteeAccepted, method: "signalingListener", data: [
            "inviteID": inviteID!,
            "invitee": invitee!,
            "data": data ?? ""
        ], listenerUuid: listenerUuid)
    }

    /// 被邀请者拒绝邀请
	public func onInviteeRejected(_ inviteID: String!, invitee: String!, data: String?) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onInviteeRejected, method: "signalingListener", data: [
            "inviteID": inviteID!,
            "invitee": invitee!,
            "data": data ?? ""
        ], listenerUuid: listenerUuid)
    }

    /// 邀请被取消
	public func onInvitationCancelled(_ inviteID: String!, inviter: String!, data: String?) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onInvitationCancelled, method: "signalingListener", data: [
            "inviteID": inviteID!,
            "inviter": inviter!,
            "data": data ?? ""
        ], listenerUuid: listenerUuid)
    }

    /// 邀请超时
    public func onInvitationTimeout(_ inviteID: String!, inviteeList: [String]!) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onInvitationTimeout, method: "signalingListener", data: [
            "inviteID": inviteID!,
            "inviteeList": inviteeList!
        ], listenerUuid: listenerUuid)
    }
}
