//
//  AdvancedMsgListener.swift
//  tencent_im_sdk_plugin

//
//  Created by 林智 on 2020/12/18.
//  let data = try Hydra.await(V2MessageEntity.init(message: msg!).getDictAll());
// TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvNewMessage, method: "advancedMsgListener", data: data)

import Foundation
import ImSDK_Plus
import Hydra

class AdvancedMsgListener: NSObject, V2TIMAdvancedMsgListener {
    let listenerUuid:String;
    init(listenerUid: String) {
        listenerUuid = listenerUid;
    }
	/// 新消息通知
	public func onRecvNewMessage(_ msg: V2TIMMessage!) {
            let promise =  Promise<Int>(in: .main,{ resolve, reject, _ in
                V2MessageEntity.init(message: msg!).getDictAll().then(in: .main,{ res in
                    TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvNewMessage, method: "advancedMsgListener", data: res, listenerUuid: self.listenerUuid)
                    resolve(1);
                })
            })
        
        HydraThreadManager.subsc(promise: promise);
	}
	
	/// C2C已读回执
	public func onRecvC2CReadReceipt(_ receiptList: [V2TIMMessageReceipt]!) {
		var data: [[String: Any]] = [];
		for item in receiptList {
			data.append(V2MessageReceiptEntity.getDict(info: item));
		}
        TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvC2CReadReceipt, method: "advancedMsgListener", data: data, listenerUuid: listenerUuid)
	}
	
	/// 消息撤回
	public func onRecvMessageRevoked(_ msgID: String!) {
        TencentImSDKPlugin.invokeListener(type: ListenerType.onRecvMessageRevoked, method: "advancedMsgListener", data: msgID, listenerUuid: listenerUuid)
	}
	
}
