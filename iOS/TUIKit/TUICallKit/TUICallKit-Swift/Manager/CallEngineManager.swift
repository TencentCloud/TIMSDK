//
//  CallEngineManager.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import TUICore
import TUICallEngine

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class CallEngineManager {
    static let instance = CallEngineManager()
    let engine = TUICallEngine.createInstance()
    
    func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        engine.setSelfInfo(nickname: nickname, avatar: avatar) {
            TUICallState.instance.selfUser.value.avatar.value = avatar
            TUICallState.instance.selfUser.value.nickname.value = nickname
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        engine.call(userId: userId, callMediaType: callMediaType, params: params) {
            User.getUserInfosFromIM(userIDs: [userId]) { mInviteeList in
                TUICallState.instance.remoteUserList.value = mInviteeList
                
                for index in 0..<TUICallState.instance.remoteUserList.value.count {
                    guard index < TUICallState.instance.remoteUserList.value.count else {
                        break
                    }
                    TUICallState.instance.remoteUserList.value[index].callStatus.value = TUICallStatus.waiting
                    TUICallState.instance.remoteUserList.value[index].callRole.value = TUICallRole.called
                }
            }
            
            TUICallState.instance.mediaType.value = callMediaType
            TUICallState.instance.scene.value = TUICallScene.single
            TUICallState.instance.selfUser.value.callRole.value = TUICallRole.call
            TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.earpiece
                TUICallState.instance.isCameraOpen.value = false
            } else if callMediaType == .video {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.speakerphone
                TUICallState.instance.isCameraOpen.value = true
            }
            
            let _ = CallingBellFeature.instance.startPlayMusic(type: .CallingBellTypeDial)
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    func groupCall(groupId: String,
                   userIdList: [String],
                   callMediaType: TUICallMediaType,
                   params: TUICallParams,
                   succ: @escaping TUICallSucc,
                   fail: @escaping TUICallFail) {
        engine.groupCall(groupId: groupId,
                         userIdList: userIdList,
                         callMediaType: callMediaType,
                         params: params) {
            TUICallState.instance.groupId.value = groupId
            
            User.getUserInfosFromIM(userIDs: userIdList) { mInviteeList in
                TUICallState.instance.remoteUserList.value = mInviteeList
                for index in 0..<TUICallState.instance.remoteUserList.value.count {
                    guard index < TUICallState.instance.remoteUserList.value.count else {
                        break
                    }
                    TUICallState.instance.remoteUserList.value[index].callStatus.value = TUICallStatus.waiting
                    TUICallState.instance.remoteUserList.value[index].callRole.value = TUICallRole.called
                }
            }
            
            TUICallState.instance.mediaType.value = callMediaType
            TUICallState.instance.scene.value = TUICallScene.group
            
            TUICallState.instance.selfUser.value.callRole.value = TUICallRole.call
            TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.earpiece
                TUICallState.instance.isCameraOpen.value = false
            } else if callMediaType == .video {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.speakerphone
                TUICallState.instance.isCameraOpen.value = true
            }
            
            let _ = CallingBellFeature.instance.startPlayMusic(type: .CallingBellTypeDial)
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func joinInGroupCall(roomId: TUIRoomId,
                         groupId: String,
                         callMediaType: TUICallMediaType,
                         succ: @escaping TUICallSucc,
                         fail: @escaping TUICallFail) {
        engine.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
            TUICallState.instance.mediaType.value = callMediaType
            TUICallState.instance.scene.value = TUICallScene.group
            TUICallState.instance.groupId.value = groupId
            
            TUICallState.instance.selfUser.value.callRole.value = TUICallRole.called
            TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.accept
            
            if callMediaType == .audio {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.earpiece
                TUICallState.instance.isCameraOpen.value = false
            } else if callMediaType == .video {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.speakerphone
                TUICallState.instance.isCameraOpen.value = true
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func hangup() {
        engine.hangup {
        } fail: { code, message in
        }
    }
    
    func accept() {
        engine.accept {
        } fail: { code, message in
        }
    }
    
    func reject() {
        engine.reject {
        } fail: { code, message in
        }
    }
    
    func muteMic() {
        if TUICallState.instance.isMicMute.value == true {
            engine.openMicrophone {
                TUICallState.instance.isMicMute.value = false
                TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                                    subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey,
                                    object: nil,
                                    param: nil)
            } fail: { code , message  in
            }
        } else {
            engine.closeMicrophone()
            TUICallState.instance.isMicMute.value = true
            TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                                subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey,
                                object: nil,
                                param: nil)
        }
    }
    
    func openMicrophone() {
        engine.openMicrophone {
            TUICallState.instance.isMicMute.value = false
            TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                                subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey,
                                object: nil,
                                param: nil)
        } fail: { code , message  in
        }
    }
    
    func closeMicrophone() {
        engine.closeMicrophone()
        TUICallState.instance.isMicMute.value = true
        TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey,
                            object: nil,
                            param: nil)
    }
    
    func changeSpeaker() {
        if TUICallState.instance.audioDevice.value == TUIAudioPlaybackDevice.speakerphone {
            engine.selectAudioPlaybackDevice(.earpiece)
            TUICallState.instance.audioDevice.value = .earpiece
        } else {
            engine.selectAudioPlaybackDevice(.speakerphone)
            TUICallState.instance.audioDevice.value = .speakerphone
        }
    }
    
    func switchCamera() {
        if TUICallState.instance.isFrontCamera.value == .front {
            engine.switchCamera(.back)
            TUICallState.instance.isFrontCamera.value = .back
        } else {
            engine.switchCamera(.front)
            TUICallState.instance.isFrontCamera.value = .front
        }
    }
    
    func closeCamera() {
        engine.closeCamera()
        TUICallState.instance.isCameraOpen.value = false
    }
    
    func openCamera(videoView: TUIVideoView) {
        engine.openCamera(TUICallState.instance.isFrontCamera.value == .front ? .front : .back, videoView: videoView) {
            TUICallState.instance.isCameraOpen.value = true
        } fail: { code, message in
        }
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView){
        engine.startRemoteView(userId: user.id.value, videoView: videoView) { userId in
        } onLoading: { userId in
        } onError: { userId, code, message in
        }
    }
    
    func stopRemoteView(user: User) {
        engine.stopRemoteView(userId: user.id.value)
    }
    
    func setAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        engine.selectAudioPlaybackDevice(device)
    }
    
    func switchToAudio() {
        engine.switchCallMediaType(.audio)
    }
    
    func inviteUser(userIds: [String]) {
        let callParams = TUICallParams()
        callParams.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        
        engine.inviteUser(userIdList: userIds, params: callParams) { userIds in
            User.getUserInfosFromIM(userIDs: userIds) { newRemoteUsers in
                for newUser in newRemoteUsers {
                    newUser.callStatus.value = TUICallStatus.waiting
                    newUser.callRole.value = TUICallRole.called
                    TUICallState.instance.remoteUserList.value.append(newUser)
                }
            }
        } fail: { code, message in
        }
    }
    
    func addObserver(_ observer: TUICallObserver) {
        engine.addObserver(observer)
    }
    
    func removeObserver(_ observer: TUICallObserver) {
        engine.removeObserver(observer)
    }
    
    func initEngine(sdkAppId: Int32, userId: String, userSig: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        engine.`init`(sdkAppId, userId: userId, userSig: userSig) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func setVideoEncoderParams(params: TUIVideoEncoderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        engine.setVideoEncoderParams(params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func setVideoRenderParams(userId: String, params: TUIVideoRenderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        engine.setVideoRenderParams(userId: userId, params: params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func getTRTCCloudInstance() -> TRTCCloud {
        return engine.getTRTCCloudInstance()
    }
    
    func setFramework() {
        var jsonParams: [String: Any]
        if TUICore.getService(TUICore_TUIChatService) == nil {
            jsonParams = ["api": "setFramework",
                          "params": ["component": 14,
                                     "language": 3,],]
        } else {
            jsonParams = ["api": "setFramework",
                          "params": ["component": 15,
                                     "language": 3,],]
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        engine.callExperimentalAPI(jsonObject: paramsString)
    }
    
    func setExcludeFromHistoryMessage() {
        if TUICore.getService(TUICore_TUIChatService) == nil {
            return
        }
        
        let jsonParams: [String: Any] = ["api": "setExcludeFromHistoryMessage",
                                         "params": ["excludeFromHistoryMessage": false,],]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        engine.callExperimentalAPI(jsonObject: paramsString)
    }
    
    func setBlurBackground() {
        let currentEnable = TUICallState.instance.enableBlurBackground.value
        let level = !currentEnable ? 3 : 0
        TUICallState.instance.enableBlurBackground.value = !currentEnable
        engine.setBlurBackground(level) { code, message in
            TUICallState.instance.enableBlurBackground.value = false
        }
    }
    
    func reportOnlineLog(_ enableVirtualBackground: Bool) {
        let msgDic: [String: Any] = ["enablevirtualbackground": enableVirtualBackground,
                                     "version": TUICALL_VERSION,
                                     "platform": "iOS",
                                     "framework": "native",
                                     "sdk_app_id": TUILogin.getSdkAppID(),]
        guard let msgData = try? JSONSerialization.data(withJSONObject: msgDic,
                                                        options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let msgString = NSString(data: msgData, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        let jsonParams: [String: Any] = ["api": "reportOnlineLog",
                                         "params": ["level": 1,
                                                    "msg":msgDic,
                                                    "more_msg":"TUICallkit"],]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        engine.getTRTCCloudInstance().callExperimentalAPI(paramsString)
    }
    
}
