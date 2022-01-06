//
//  SimpleMsgListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

class SimpleMsgListener: NSObject, V2TIMSimpleMsgListener {
    let listenerUuid: String;
    
    init(listenerUid: String) {
        listenerUuid = listenerUid;
    }
	/// simpleMsgListener
	public func onRecvC2CTextMessage(_ msgID: String!, sender: V2TIMUserInfo, text: String) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvC2CTextMessage, method: "simpleMsgListener", data: ["msgID": msgID!, "text": text, "sender": V2UserInfoEntity.getDict(info: sender)], listenerUuid: listenerUuid)
	}
	
	public func onRecvC2CCustomMessage(_ msgID: String!, sender: V2TIMUserInfo, customData: Data) {
		let str = String.init(data: customData, encoding: String.Encoding.utf8)
		 TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvC2CCustomMessage, method: "simpleMsgListener", data: ["msgID": msgID, "customData": str, "sender": V2UserInfoEntity.getDict(info: sender)], listenerUuid: "")
	}
	
	public func onRecvGroupTextMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, text: String!) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvGroupTextMessage, method: "simpleMsgListener", data: ["msgID": msgID!, "text": text!, "groupID": groupID!, "sender": V2GroupMemberFullInfoEntity.getDict(simpleInfo: info)], listenerUuid: listenerUuid)
	}
	
	public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
		let str = String.init(data: data, encoding: String.Encoding.utf8)
		TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvGroupCustomMessage, method: "simpleMsgListener", data: ["msgID": msgID!, "customData": str!, "groupID": groupID!, "sender": V2GroupMemberFullInfoEntity.getDict(simpleInfo: info)], listenerUuid: listenerUuid)
	}
}
