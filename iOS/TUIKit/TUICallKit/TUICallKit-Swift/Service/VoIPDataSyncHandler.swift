//
//  VoIPDataSyncHandler.swift
//  Pods
//
//  Created by vincepzhang on 2024/11/25.
//

import Foundation
import TUICore
import TUICallEngine
import UIKit

class VoIPDataSyncHandler {
        
    func onCall(_ method: String, param: [AnyHashable : Any]?) {
        guard let param = param else { return }
        
         if method == TUICore_TUICallingService_SetAudioPlaybackDeviceMethod {
            let key = TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice
            guard let value = param[key] as? UInt else { return }
            let audioPlaybackDevice: TUIAudioPlaybackDevice
            switch value {
            case TUIAudioPlaybackDevice.earpiece.rawValue:
                audioPlaybackDevice = .earpiece
            default:
                audioPlaybackDevice = .speakerphone
            }
             
             Logger.info("VoIPDataSyncHandler - onCall - selectAudioPlaybackDevice. deivce:\(audioPlaybackDevice)")
            CallEngineManager.instance.selectAudioPlaybackDevice(device: audioPlaybackDevice)
        } else if method == TUICore_TUICallingService_SetIsMicMuteMethod {
            guard let isMicMute = param[TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute] as? Bool else {
                return
            }

            if isMicMute {
                Logger.info("VoIPDataSyncHandler - onCall - closeMicrophone")
                CallEngineManager.instance.closeMicrophone(false)
            } else {
                Logger.info("VoIPDataSyncHandler - onCall - openMicrophone")
                CallEngineManager.instance.openMicrophone(false)
            }
        } else if method == TUICore_TUICallingService_HangupMethod {
            if TUICallState.instance.selfUser.value.callStatus.value == .accept {
                Logger.info("VoIPDataSyncHandler - onCall - hangup")
                CallEngineManager.instance.hangup()
            } else {
                Logger.info("VoIPDataSyncHandler - onCall - reject")
                CallEngineManager.instance.reject()
            }
        } else if  method == TUICore_TUICallingService_AcceptMethod {
            Logger.info("VoIPDataSyncHandler - onCall - accept")
            CallEngineManager.instance.accept()
        }
    }
    
    
    func setVoIPMuteForTUICallKitVoIPExtension(_ mute: Bool) {
        TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                            subKey: mute ? TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey :
                                TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey,
                            object: nil,
                            param: nil)
    }
    
    func setVoIPMute(_ mute: Bool) {
        Logger.info("VoIPDataSyncHandler - setVoIPMute. mute:\(mute)")

        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey_IsMuteKey: mute])

    }
    
    func closeVoIP() {
        Logger.info("VoIPDataSyncHandler - closeVoIP")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_EndSubKey,
                            object: nil,
                            param: nil)
    }
    
    func callBegin() {
        Logger.info("VoIPDataSyncHandler - callBegin")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_ConnectedKey,
                            object: nil,
                            param: nil)
    }
    
    func updateVoIPInfo(callerId: String, calleeList: [String], groupId: String) {
        Logger.info("VoIPDataSyncHandler - updateInfo")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviterIdKey: callerId,
                                  TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviteeListKey: calleeList,
                                      TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_GroupIDKey: groupId])
    }
}
