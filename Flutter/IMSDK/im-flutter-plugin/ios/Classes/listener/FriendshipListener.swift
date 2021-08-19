//
//  FriendsshipListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

class FriendshipListener: NSObject, V2TIMFriendshipListener {
	
	public func onFriendApplicationListAdded(_ applicationList: [V2TIMFriendApplication]!) {
		var data: [[String: Any]] = [];
		for item in applicationList {
			data.append(V2FriendApplicationEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendApplicationListAdded, method: "friendListener", data: data)
	}
	
	public func onFriendApplicationListDeleted(_ userIDList: [Any]!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendApplicationListDeleted, method: "friendListener", data: userIDList)
	}
	
	public func onFriendApplicationListRead() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendApplicationListRead, method: "friendListener", data: nil)
	}
	
	public func onFriendListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendListAdded, method: "friendListener", data: data)
	}
	
	public func onFriendListDeleted(_ userIDList: [Any]!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendListDeleted, method: "friendListener", data: userIDList)
	}
	
	
	public func onBlackListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onBlackListAdd, method: "friendListener", data: data)
	}
	
	public func onBlackListDeleted(_ userIDList: [Any]!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onBlackListDeleted, method: "friendListener", data: userIDList)
	}
	
	public func onFriendProfileChanged(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onFriendInfoChanged, method: "friendListener", data: data)
	}
	
}
