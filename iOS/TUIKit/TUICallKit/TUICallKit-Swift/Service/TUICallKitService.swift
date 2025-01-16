//
//  TUICallKitService.swift
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
            guard let userID = userIDs.first else {
                return
            }
            TUICallKit.createInstance().call(userId: userID, callMediaType: callingType)
        } else {
            TUICallKit.createInstance().groupCall(groupId: groupID, userIdList: userIDs, callMediaType: callingType)
        }
    }
}

// MARK: TUIServiceProtocol
extension TUICallKitService {
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        guard let param = param else {
            return nil
        }
                
        if method == TUICore_TUICallingService_EnableFloatWindowMethod {
            guard let enableFloatWindow = param[TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow] as? Bool else {
                return nil
            }
            TUICallKit.createInstance().enableFloatWindow(enable: enableFloatWindow)
        } else if method == TUICore_TUICallingService_EnableIncomingBannerMethod {
            guard let enableIncomingBanner = param[TUICore_TUICallingService_EnableIncomingBannerMethod_EnableIncomingBanner] as? Bool else {
                return nil
            }
            TUICallKit.createInstance().enableIncomingBanner(enable: enableIncomingBanner)
        } else if method == TUICore_TUICallingService_EnableVirtualBackgroundForCallMethod {
            guard let enableVirtualBackground = param[TUICore_TUICallingService_EnableVirtualBackgroundForCallMethod_EnableVirtualBackgroundForCall] as? Bool else {
                return nil
            }
            TUICallKit.createInstance().enableVirtualBackground(enable: enableVirtualBackground)
        } else if method == TUICore_TUICallingService_ShowCallingViewMethod {
            guard let userIDs = param[TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey] as? [ String],
                  let mediaTypeIndex = param[TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey] as? String else {
                return nil
            }
            
            var mediaType: TUICallMediaType = .unknown
            if mediaTypeIndex == "0" {
                mediaType = .audio
            } else if mediaTypeIndex == "1" {
                mediaType = .video
            }
            let groupId = param[TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey] as? String ?? ""
            startCall(groupID: groupId, userIDs: userIDs, callingType: mediaType)
        } else if method == TUICore_TUICallingService_ReceivePushCallingMethod {
            guard let signalingInfo = param[TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo] as? V2TIMSignalingInfo else {
                return nil
            }
            let selector = NSSelectorFromString("onReceiveGroupCallAPNs:")
            if TUICallEngine.createInstance().responds(to: selector) {
                TUICallEngine.createInstance().perform(selector, with: signalingInfo)
            }
        } else if method == TUICore_TUICallingService_EnableMultiDeviceAbilityMethod {
            let key = TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility
            guard let enableMultiDeviceAbility = param[key] as? Bool else {
                return nil
            }
            TUICallEngine.createInstance().enableMultiDeviceAbility(enable: enableMultiDeviceAbility) {
                
            } fail: { code, message in
                
            }
        } else {
            CallEngineManager.instance.voipDataSyncHandler.onCall(method, param: param)
        }
        
        return nil
    }
}
