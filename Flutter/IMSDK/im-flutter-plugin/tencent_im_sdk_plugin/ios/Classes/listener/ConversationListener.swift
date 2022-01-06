//
//  ConversationListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus
import Hydra

class ConversationListener: NSObject, V2TIMConversationListener {
    let listenerUuid:String;

	init(listenerUid:String) {
		listenerUuid = listenerUid;
	}
	/// 会话刷新
	public func onConversationChanged(_ conversationList: [V2TIMConversation]!) {
	// 	var cs: [[String: Any]] = [];
		
	// 	for item in conversationList {
	// 		cs.append(V2ConversationEntity.getDict(info: item));
	// 	}
	// 	TencentImSDKPlugin.invokeListener(type: ListenerType.onConversationChanged, method: "conversationListener", data: cs)
		
	async({
			_ -> Int in
            var cs: [[String: Any]] = [];
			for item in conversationList {
				cs.append(try Hydra.await (V2ConversationEntity.getDictAll(info: item)));
			}
        TencentImSDKPlugin.invokeListener(type: ListenerType.onConversationChanged, method: "conversationListener", data: cs, listenerUuid: self.listenerUuid)
			return 1
		}).then({
			value in
		})
		
	}
	
	/// 新会话
	public func onNewConversation(_ conversationList: [V2TIMConversation]!) {
		var cs: [[String: Any]] = [];
		for item in conversationList {
			cs.append(V2ConversationEntity.getDict(info: item));
		}
		TencentImSDKPlugin.invokeListener(type: ListenerType.onNewConversation, method: "conversationListener", data: cs, listenerUuid: listenerUuid)
	}

	/// 同步服务开始
	public func onSyncServerStart() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onSyncServerStart, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 同步服务完成
	public func onSyncServerFinish() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onSyncServerFinish, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 同步服务失败
	public func onSyncServerFailed() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onSyncServerFailed, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	// 未读数改变
	public func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onTotalUnreadMessageCountChanged, method: "conversationListener", data: totalUnreadCount, listenerUuid: listenerUuid)
	}
}
