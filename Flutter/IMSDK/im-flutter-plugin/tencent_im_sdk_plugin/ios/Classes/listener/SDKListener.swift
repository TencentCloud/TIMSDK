//
//  SDKListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

class SDKListener: NSObject, V2TIMSDKListener {
    let listenerUuid:String;
    init(listenerUid:String) {
        listenerUuid = listenerUid;
    }
	/// 连接中
	public func onConnecting() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onConnecting, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 网络连接成功
	public func onConnectSuccess() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onConnectSuccess, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 网络连接失败
	public func onConnectFailed(_ code: Int32, err: String!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onConnectFailed, method: "initSDKListener", data: [
			"code": code,
            "desc": err!,
		], listenerUuid: listenerUuid)
	}
	
	/// 踢下线通知
	public func onKickedOffline() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onKickedOffline, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 用户登录的 userSig 过期（用户需要重新获取 userSig 后登录）
	public func onUserSigExpired() {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onUserSigExpired, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 当前用户的资料发生了更新
	public func onSelfInfoUpdated(_ Info: V2TIMUserFullInfo!) {
		TencentImSDKPlugin.invokeListener(type: ListenerType.onSelfInfoUpdated, method: "initSDKListener", data: V2UserFullInfoEntity.getDict(info: Info), listenerUuid: listenerUuid)
	}
	
}
