//
//  VoIPDataSyncHandler.swift
//  Pods
//
//  Created by vincepzhang on 2024/11/25.
//

import Foundation
import TUICore
import RTCRoomEngine
import RTCCommon
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
            TRTCLog.info("VoIPDataSyncHandler - onCall - selectAudioPlaybackDevice. deivce:\(audioPlaybackDevice)")
            CallManager.shared.selectAudioPlaybackDevice(device: audioPlaybackDevice)
        } else if method == TUICore_TUICallingService_SetIsMicMuteMethod {
            guard let isMicMute = param[TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute] as? Bool else {
                return
            }

            if isMicMute {
                TRTCLog.info("VoIPDataSyncHandler - onCall - closeMicrophone")
                CallManager.shared.closeMicrophone(false)
            } else {
                TRTCLog.info("VoIPDataSyncHandler - onCall - openMicrophone")
                CallManager.shared.openMicrophone(false) { } fail: { code, message in }
            }
        } else if method == TUICore_TUICallingService_HangupMethod {
            if CallManager.shared.userState.selfUser.callStatus.value == .accept {
                TRTCLog.info("VoIPDataSyncHandler - onCall - hangup")
                CallManager.shared.hangup() { } fail: { code, message in }
            } else {
                TRTCLog.info("VoIPDataSyncHandler - onCall - reject")
                CallManager.shared.reject() { } fail: { code, message in }
            }
        } else if  method == TUICore_TUICallingService_AcceptMethod {
            TRTCLog.info("VoIPDataSyncHandler - onCall - accept")
            CallManager.shared.accept() { } fail: { code, message in }
        }
    }
        
    func setVoIPMute(_ mute: Bool) {
        TRTCLog.info("VoIPDataSyncHandler - setVoIPMute. mute:\(mute)")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey_IsMuteKey: mute])

    }
    
    func closeVoIP() {
        TRTCLog.info("VoIPDataSyncHandler - closeVoIP")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_EndSubKey,
                            object: nil,
                            param: nil)
    }
    
    func callBegin() {
        TRTCLog.info("VoIPDataSyncHandler - callBegin")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_ConnectedKey,
                            object: nil,
                            param: nil)
    }
    
    func updateVoIPInfo(callerId: String, calleeList: [String], groupId: String, mediaType: TUICallMediaType) {
        TRTCLog.info("VoIPDataSyncHandler - updateInfo")
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviterIdKey: callerId,
                                  TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviteeListKey: calleeList,
                                      TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_GroupIDKey: groupId,
                                    TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_MediaTypeKey: mediaType.rawValue])
    }
}
