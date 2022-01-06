//
//  GroupListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

class GroupListener: NSObject, V2TIMGroupListener {
    let listenerUuid: String;
    
    
    init(listenerUid:String) {
        listenerUuid = listenerUid;
    }
	public func onMemberEnter(_ groupID: String!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onMemberEnter, method: "groupListener", data: [
			"groupID": groupID,
			"memberList": data,
		], listenerUuid: listenerUuid)
	}
	
	/// 有用户离开群（全员能够收到）
	public func onMemberLeave(_ groupID: String!, member: V2TIMGroupMemberInfo!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onMemberLeave, method: "groupListener", data: [
			"groupID": groupID,
			"member": V2GroupMemberFullInfoEntity.getDict(simpleInfo: member!),
		], listenerUuid: listenerUuid)
	}
	
	
	/// 某些人被拉入某群（全员能够收到）
	public func onMemberInvited(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onMemberInvited, method: "groupListener", data: [
			"groupID": groupID,
			"memberList": data,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser!),
		], listenerUuid: listenerUuid)
	}
	
	/// 某些人被踢出某群（全员能够收到）
	public func onMemberKicked(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onMemberKicked, method: "groupListener", data: [
			"groupID": groupID,
			"memberList": data,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser!),
		],listenerUuid: listenerUuid)
	}
	
	/// 群成员信息被修改（全员能收到）
	public func onMemberInfoChanged(_ groupID: String!, changeInfoList: [V2TIMGroupMemberChangeInfo]!) {
		var data: [[String: Any]] = [];
		for item in changeInfoList! {
			data.append(V2GroupMemberChangeInfoEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onMemberInfoChanged, method: "groupListener", data: [
			"groupID": groupID,
			"groupMemberChangeInfoList": data,
		], listenerUuid: listenerUuid)
	}
	
	/// 创建群（主要用于多端同步）
	public func onGroupCreated(_ groupID: String!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGroupCreated, method: "groupListener", data: ["groupID": groupID], listenerUuid: listenerUuid)
	}
	
	/// 群被解散了（全员能收到）
	public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGroupDismissed, method: "groupListener", data: [
			"groupID": groupID,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
		], listenerUuid: listenerUuid)
	}
	
	/// 群被回收（全员能收到）
	public func onGroupRecycled(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGroupRecycled, method: "groupListener", data: [
			"groupID": groupID,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
		], listenerUuid: listenerUuid)
	}
	
	/// 群信息被修改（全员能收到）
	public func onGroupInfoChanged(_ groupID: String!, changeInfoList: [V2TIMGroupChangeInfo]!) {
		var data: [[String: Any]] = [];
		for item in changeInfoList! {
			data.append(V2GroupChangeInfoEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGroupInfoChanged, method: "groupListener", data: [
			"groupID": groupID,
			"groupChangeInfoList": data,
		], listenerUuid: listenerUuid)
	}
	
	/// 有新的加群请求（只有群主或管理员会收到）
	public func onReceiveJoinApplication(_ groupID: String!, member: V2TIMGroupMemberInfo!, opReason: String!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onReceiveJoinApplication, method: "groupListener", data: [
			"groupID": groupID,
			"member": V2GroupMemberFullInfoEntity.getDict(simpleInfo: member),
			"opReason": opReason,
		], listenerUuid: listenerUuid)
	}
	
	/// 加群请求已经被群主或管理员处理了（只有申请人能够收到）
	public func onApplicationProcessed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, opResult isAgreeJoin: Bool, opReason: String!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onApplicationProcessed, method: "groupListener", data: [
			"groupID": groupID,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"isAgreeJoin": isAgreeJoin,
			"opReason": opReason,
		], listenerUuid: listenerUuid)
	}
	
	/// 指定管理员身份
	public func onGrantAdministrator(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGrantAdministrator, method: "groupListener", data: [
			"groupID": groupID,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"memberList": data,
		], listenerUuid: listenerUuid)
	}
	
	/// 取消管理员身份
	public func onRevokeAdministrator(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onRevokeAdministrator, method: "groupListener", data: [
			"groupID": groupID,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"memberList": data,
		], listenerUuid: listenerUuid)
	}
	
	/// 主动退出群组（主要用于多端同步，直播群（AVChatRoom）不支持）
	public func onQuit(fromGroup groupID: String!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onQuitFromGroup, method: "groupListener", data: ["groupID": groupID], listenerUuid: listenerUuid)
	}
	
	/// 收到 RESTAPI 下发的自定义系统消息
	public func onReceiveRESTCustomData(_ groupID: String!, data: Data!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onReceiveRESTCustomData, method: "groupListener", data: [
			"groupID": groupID!,
			"customData": String.init(data: data!, encoding: String.Encoding.utf8)!,
		], listenerUuid: listenerUuid)
	}
	
	public func onGroupAttributeChanged(_ groupID: String!, attributes: NSMutableDictionary!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onGroupAttributeChanged, method: "groupListener", data: [
			"groupID": groupID!,
			"groupAttributeMap": attributes!,
		], listenerUuid: listenerUuid)
	}
	
}
