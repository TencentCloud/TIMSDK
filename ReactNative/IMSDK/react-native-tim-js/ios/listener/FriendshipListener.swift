import Foundation
import ImSDK_Plus

class FriendshipListener: NSObject, V2TIMFriendshipListener {
	let eventName: String = "friendListener";
	
	public func onFriendApplicationListAdded(_ applicationList: [V2TIMFriendApplication]!) {
		var data: [[String: Any]] = [];
		for item in applicationList {
			data.append(V2FriendApplicationEntity.getDict(info: item));
		}
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendApplicationListAdded, data: data);
	}
	
	public func onFriendApplicationListDeleted(_ userIDList: [Any]!) {
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendApplicationListDeleted, data: userIDList);
	}
	
	public func onFriendApplicationListRead() {
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendApplicationListRead, data: nil);
	}
	
	public func onFriendListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendListAdded, data: data);
	}
	
	public func onFriendListDeleted(_ userIDList: [Any]!) {
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendListDeleted, data: userIDList);
	}
	
	
	public func onBlackListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onBlackListAdd, data: data);
	}
	
	public func onBlackListDeleted(_ userIDList: [Any]!) {
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onBlackListDeleted, data: userIDList);
	}
	
	public func onFriendProfileChanged(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onFriendInfoChanged, data: data);
	}
	
}
