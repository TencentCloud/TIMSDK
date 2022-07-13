import Foundation
import ImSDK_Plus

class GroupListener: NSObject, V2TIMGroupListener {
    let eventName: String = "groupListener";

	public func onMemberEnter(_ groupID: String!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onMemberEnter, data: [
            "groupID": groupID as Any,
			"memberList": data,
		]);
	}
	
	/// 有用户离开群（全员能够收到）
	public func onMemberLeave(_ groupID: String!, member: V2TIMGroupMemberInfo!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onMemberLeave, data: [
            "groupID": groupID as Any,
			"memberList": V2GroupMemberFullInfoEntity.getDict(simpleInfo: member!),
		]);
	}
	
	
	/// 某些人被拉入某群（全员能够收到）
	public func onMemberInvited(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onMemberInvited, data: [
            "groupID": groupID  as Any,
			"memberList": data,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser!),
		]);
	}
	
	/// 某些人被踢出某群（全员能够收到）
	public func onMemberKicked(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onMemberKicked, data: [
            "groupID": groupID  as Any,
			"memberList": data,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser!),
		]);
	}
	
	/// 群成员信息被修改（全员能收到）
	public func onMemberInfoChanged(_ groupID: String!, changeInfoList: [V2TIMGroupMemberChangeInfo]!) {
		var data: [[String: Any]] = [];
		for item in changeInfoList! {
			data.append(V2GroupMemberChangeInfoEntity.getDict(info: item));
		}

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onMemberInfoChanged, data: [
            "groupID": groupID  as Any,
			"groupMemberChangeInfoList": data,
		]);
	}
	
	/// 创建群（主要用于多端同步）
	public func onGroupCreated(_ groupID: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onGroupCreated, data: ["groupID": groupID]);
	}
	
	/// 群被解散了（全员能收到）
	public func onGroupDismissed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onGroupDismissed, data: [
            "groupID": groupID  as Any,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
		]);
	}
	
	/// 群被回收（全员能收到）
	public func onGroupRecycled(_ groupID: String!, opUser: V2TIMGroupMemberInfo!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onGroupRecycled, data: [
            "groupID": groupID as Any,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
		]);
	}
	
	/// 群信息被修改（全员能收到）
	public func onGroupInfoChanged(_ groupID: String!, changeInfoList: [V2TIMGroupChangeInfo]!) {
		var data: [[String: Any]] = [];
		for item in changeInfoList! {
			data.append(V2GroupChangeInfoEntity.getDict(info: item));
		}

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onGroupInfoChanged, data: [
            "groupID": groupID as Any,
			"groupChangeInfoList": data,
		]);
	}
	
	/// 有新的加群请求（只有群主或管理员会收到）
	public func onReceiveJoinApplication(_ groupID: String!, member: V2TIMGroupMemberInfo!, opReason: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onReceiveJoinApplication, data: [
            "groupID": groupID as Any,
			"member": V2GroupMemberFullInfoEntity.getDict(simpleInfo: member),
            "opReason": opReason as Any,
		]);
	}
	
	/// 加群请求已经被群主或管理员处理了（只有申请人能够收到）
	public func onApplicationProcessed(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, opResult isAgreeJoin: Bool, opReason: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onApplicationProcessed, data: [
            "groupID": groupID as Any,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"isAgreeJoin": isAgreeJoin,
            "opReason": opReason as Any,
		]);
	}
	
	/// 指定管理员身份
	public func onGrantAdministrator(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onApplicationProcessed, data: [
            "groupID": groupID as Any,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"memberList": data,
		]);
	}
	
	/// 取消管理员身份
	public func onRevokeAdministrator(_ groupID: String!, opUser: V2TIMGroupMemberInfo!, memberList: [V2TIMGroupMemberInfo]!) {
		var data: [[String: Any]] = [];
		for item in memberList! {
			data.append(V2GroupMemberFullInfoEntity.getDict(simpleInfo: item));
		}

        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRevokeAdministrator, data: [
            "groupID": groupID as Any,
			"opUser": V2GroupMemberFullInfoEntity.getDict(simpleInfo: opUser),
			"memberList": data,
		]);
	}
	
	/// 主动退出群组（主要用于多端同步，直播群（AVChatRoom）不支持）
	public func onQuit(fromGroup groupID: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onQuitFromGroup, data: ["groupID": groupID]);
	}
	
	/// 收到 RESTAPI 下发的自定义系统消息
	public func onReceiveRESTCustomData(_ groupID: String!, data: Data!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRevokeAdministrator, data: [
			"groupID": groupID ?? "",
			"customData": String.init(data: data!, encoding: String.Encoding.utf8)!,
		]);
	}
	
	public func onGroupAttributeChanged(_ groupID: String!, attributes: NSMutableDictionary!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onGroupAttributeChanged, data: [
			"groupID": groupID ?? "",
			"groupAttributeMap": attributes ?? NSMutableDictionary(),
		]);
	}
	
}
