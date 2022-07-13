//
//  APNSListener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import ImSDK_Plus

class APNSListener: NSObject, V2TIMAPNSListener {
	public static var count: UInt32 = 0;
	
	public func onSetAPPUnreadCount() -> UInt32 {
		return APNSListener.count;
	}
	
}
