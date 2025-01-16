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
    let voipDataSyncHandler = VoIPDataSyncHandler()
    
    func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setSelfInfo(nickname: nickname, avatar: avatar) {
            TUICallState.instance.selfUser.value.avatar.value = avatar
            TUICallState.instance.selfUser.value.nickname.value = nickname
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().call(userId: userId, callMediaType: callMediaType, params: params) {
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
        TUICallEngine.createInstance().groupCall(groupId: groupId,
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
        TUICallEngine.createInstance().joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
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
        TUICallEngine.createInstance().hangup {
        } fail: { code, message in
        }
    }
    
    func accept() {
        TUICallEngine.createInstance().accept {
        } fail: { code, message in
        }
    }
    
    func reject() {
        TUICallEngine.createInstance().reject {
        } fail: { code, message in
        }
    }
    
    func muteMic() {
        if TUICallState.instance.isMicMute.value == true {
            TUICallEngine.createInstance().openMicrophone { [weak self] in
                guard let self = self else { return }
                TUICallState.instance.isMicMute.value = false
                self.voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(false)
                self.voipDataSyncHandler.setVoIPMute(false)
            } fail: { code , message  in
            }
        } else {
            TUICallEngine.createInstance().closeMicrophone()
            TUICallState.instance.isMicMute.value = true
            voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(true)
            voipDataSyncHandler.setVoIPMute(true)
        }
    }
    
    func openMicrophone(_ notifyEvent: Bool = true) {
        if TUICallState.instance.selfUser.value.callStatus.value != .none {
            TUICallEngine.createInstance().openMicrophone { [weak self] in
                guard let self = self else { return }
                TUICallState.instance.isMicMute.value = false
                if (notifyEvent) {
                    self.voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(false)
                    self.voipDataSyncHandler.setVoIPMute(false)
                }
            } fail: { code , message  in
            }
        }
    }
    
    func closeMicrophone(_ notifyEvent: Bool = true) {
        TUICallEngine.createInstance().closeMicrophone()
        TUICallState.instance.isMicMute.value = true
        if (notifyEvent) {
            voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(true)
            voipDataSyncHandler.setVoIPMute(true)
        }
    }
    
    func changeSpeaker() {
        if TUICallState.instance.audioDevice.value == TUIAudioPlaybackDevice.speakerphone {
            selectAudioPlaybackDevice(device: .earpiece)
        } else {
            selectAudioPlaybackDevice(device: .speakerphone)
        }
    }
    
    func selectAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        TUICallEngine.createInstance().selectAudioPlaybackDevice(device)
        TUICallState.instance.audioDevice.value = device
    }
    
    func switchCamera() {
        if TUICallState.instance.isFrontCamera.value == .front {
            TUICallEngine.createInstance().switchCamera(.back)
            TUICallState.instance.isFrontCamera.value = .back
        } else {
            TUICallEngine.createInstance().switchCamera(.front)
            TUICallState.instance.isFrontCamera.value = .front
        }
    }
    
    func closeCamera() {
        TUICallEngine.createInstance().closeCamera()
        TUICallState.instance.isCameraOpen.value = false
    }
    
    func openCamera(videoView: TUIVideoView) {
        TUICallEngine.createInstance().openCamera(TUICallState.instance.isFrontCamera.value == .front ? .front : .back, videoView: videoView) {
            TUICallState.instance.isCameraOpen.value = true
        } fail: { code, message in
        }
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView){
        TUICallEngine.createInstance().startRemoteView(userId: user.id.value, videoView: videoView) { userId in
        } onLoading: { userId in
        } onError: { userId, code, message in
        }
    }
    
    func stopRemoteView(user: User) {
        TUICallEngine.createInstance().stopRemoteView(userId: user.id.value)
    }
    
    func setAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        TUICallEngine.createInstance().selectAudioPlaybackDevice(device)
    }
    
    func switchToAudio() {
        TUICallEngine.createInstance().switchCallMediaType(.audio)
    }
    
    func inviteUser(userIds: [String]) {
        let callParams = TUICallParams()
        callParams.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        
        TUICallEngine.createInstance().inviteUser(userIdList: userIds, params: callParams) { userIds in
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
        TUICallEngine.createInstance().addObserver(observer)
    }
    
    func removeObserver(_ observer: TUICallObserver) {
        TUICallEngine.createInstance().removeObserver(observer)
    }
    
    func initEngine(sdkAppId: Int32, userId: String, userSig: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().`init`(sdkAppId, userId: userId, userSig: userSig) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func setVideoEncoderParams(params: TUIVideoEncoderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setVideoEncoderParams(params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func setVideoRenderParams(userId: String, params: TUIVideoRenderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setVideoRenderParams(userId: userId, params: params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func getTRTCCloudInstance() -> TRTCCloud {
        return TUICallEngine.createInstance().getTRTCCloudInstance()
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
        
        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: paramsString)
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
        
        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: paramsString)
    }
    
    func setBlurBackground() {
        let currentEnable = TUICallState.instance.enableBlurBackground.value
        let level = !currentEnable ? 3 : 0
        TUICallState.instance.enableBlurBackground.value = !currentEnable
        TUICallEngine.createInstance().setBlurBackground(level) { code, message in
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
        TUICallEngine.createInstance().getTRTCCloudInstance().callExperimentalAPI(paramsString)
    }
    
    func closeVoIP() {
        voipDataSyncHandler.closeVoIP()
    }
    
    func callBegin() {
        voipDataSyncHandler.callBegin()
    }
    
    func updateVoIPInfo(callerId: String, calleeList: [String], groupId: String) {
        voipDataSyncHandler.updateVoIPInfo(callerId: callerId, calleeList: calleeList, groupId: groupId)
    }
    
}
