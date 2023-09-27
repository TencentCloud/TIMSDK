//
//  File.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/20.
//

import Foundation
import TUICore
import TUICallEngine
import UIKit

class TUICallKitService: NSObject, TUIServiceProtocol {
    static let instance = TUICallKitService()
        
    func startCall(groupID: String, userIDs: [String], callingType: TUICallMediaType) {
        let selector = NSSelectorFromString("setOnlineUserOnly")
        if TUICallEngine.createInstance().responds(to: selector) {
            TUICallEngine.createInstance().perform(selector, with: 0)
        }
        
        if groupID.isEmpty {
            guard let userID = userIDs.first else { return }
            TUICallKit.createInstance().call(userId: userID, callMediaType: callingType)
        } else {
            TUICallKit.createInstance().groupCall(groupId: groupID, userIdList: userIDs, callMediaType: callingType)
        }
    }
}

// MARK: TUIServiceProtocol
extension TUICallKitService {
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        guard let param = param else { return nil }
        if param.isEmpty {
            return nil
        }
        
        if method == TUICore_TUICallingService_EnableFloatWindowMethod {
            let key = TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow
            guard let enableFloatWindow = param[key] as? Bool else { return nil }
            TUICallKit.createInstance().enableFloatWindow(enable: enableFloatWindow)
        } else if method == TUICore_TUICallingService_ShowCallingViewMethod {
            guard let userIDs = param[TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey] as? [ String] else { return nil }
            guard let mediaTypeIndex = param[TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey] as? Int else { return nil }
            var mediaType: TUICallMediaType = .unknown
            if mediaTypeIndex == 0 {
                mediaType = .audio
            } else if mediaTypeIndex == 1 {
                mediaType = .video
            }
            guard let groupID = param[TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey] as? String else { return nil }
            startCall(groupID: groupID, userIDs: userIDs, callingType: mediaType)
        } else if method == TUICore_TUICallingService_ReceivePushCallingMethod {
            guard let signalingInfo = param[TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo] as? V2TIMSignalingInfo else { return nil }
            let groupID = signalingInfo.groupID
            
            var selector = NSSelectorFromString("onReceiveGroupCallAPNs")
            if TUICallEngine.createInstance().responds(to: selector) {
                TUICallEngine.createInstance().perform(selector, with: signalingInfo)
            }
        } else if method == TUICore_TUICallingService_EnableMultiDeviceAbilityMethod {
            guard let enableMultiDeviceAbility = param[TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility]
                    as? Bool else { return nil }
            TUICallEngine.createInstance().enableMultiDeviceAbility(enable: enableMultiDeviceAbility) {
                
            } fail: { code, message in
                
            }
        }
        return nil
    }
}
