import Foundation
import ImSDK_Plus

class SDKListener: NSObject, V2TIMSDKListener {
    let eventName: String = "sdkListener";

	/// 连接中
	public func onConnecting() {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onConnecting, data: nil);
	}
	
	/// 网络连接成功
	public func onConnectSuccess() {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onConnectSuccess, data: nil);
	}
	
	/// 网络连接失败
	public func onConnectFailed(_ code: Int32, err: String!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onConnectFailed, data: ["code": code, "desc": err!]);
	}
	
	/// 踢下线通知
	public func onKickedOffline() {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onKickedOffline, data: nil);
	}
	
	/// 用户登录的 userSig 过期（用户需要重新获取 userSig 后登录）
	public func onUserSigExpired() {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onUserSigExpired, data: nil);
	}
	
	/// 当前用户的资料发生了更新
	public func onSelfInfoUpdated(_ Info: V2TIMUserFullInfo!) {
        CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onSelfInfoUpdated, data: V2UserFullInfoEntity.getDict(info: Info));
	}

	public func onUserStatusChanged(_ statusList: [V2TIMUserStatus]!){
        var data:[String:Any] = [:];
        var res: [[String: Any]] = []
        statusList?.forEach({ status in
            var item: [String: Any] = [:]
            item["customStatus"] = status.customStatus ?? "";
            item["statusType"] = status.statusType.rawValue;
            item["userID"] = status.userID;
            res.append(item)
        })
        data["statusList"] = res;
		CommonUtils.emmitEvent(eventName: eventName, eventType: ListenerType.onUserStatusChanged, data: data);
    }
	
}
