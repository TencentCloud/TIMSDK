import Foundation
import ImSDK_Plus

class SimpleMsgListener: NSObject, V2TIMSimpleMsgListener {
    let eventName: String = "simpleMsgListener";

	/// simpleMsgListener
	public func onRecvC2CTextMessage(_ msgID: String!, sender: V2TIMUserInfo, text: String) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRecvC2CTextMessage, data: ["msgID": msgID ?? "", "text": text, "sender": V2UserInfoEntity.getDict(info: sender)]);
	}
	
	public func onRecvC2CCustomMessage(_ msgID: String!, sender: V2TIMUserInfo, customData: Data) {
		let str = String.init(data: customData, encoding: String.Encoding.utf8)
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRecvC2CCustomMessage, data: ["msgID": msgID ?? "", "customData": str ?? "", "sender": V2UserInfoEntity.getDict(info: sender)]);
	}
	
	public func onRecvGroupTextMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, text: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRecvGroupTextMessage, data: ["msgID": msgID ?? "", "text": text ?? "", "groupID": groupID ?? "", "sender": V2GroupMemberFullInfoEntity.getDict(simpleInfo: info)]);
	}
	
	public func onRecvGroupCustomMessage(_ msgID: String!, groupID: String!, sender info: V2TIMGroupMemberInfo!, customData data: Data!) {
		let str = String.init(data: data, encoding: String.Encoding.utf8)
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onRecvGroupCustomMessage, data: ["msgID": msgID ?? "", "customData": str ?? "", "groupID": groupID ?? "", "sender": V2GroupMemberFullInfoEntity.getDict(simpleInfo: info)]);
	}
}
