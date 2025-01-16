//
//  TUICallState.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import TUICore
import TUICallEngine
import AVFoundation

class TUICallState: NSObject {
    static let instance = TUICallState()
    
    let remoteUserList: Observable<[User]> = Observable(Array())
    let selfUser: Observable<User> = Observable(User())
    
    let scene: Observable<TUICallScene> = Observable(TUICallScene.single)
    let mediaType: Observable<TUICallMediaType> = Observable(TUICallMediaType.unknown)
    let timeCount: Observable<Int> = Observable(0)
    let groupId: Observable<String> = Observable("")
    let event: Observable<TUICallEvent> = Observable(TUICallEvent(eventType: .UNKNOWN, event: .UNKNOWN, param: Dictionary()))
    
    let isCameraOpen: Observable<Bool> = Observable(false)
    let isMicMute: Observable<Bool> = Observable(false)
    let isFrontCamera: Observable<TUICamera> = Observable(TUICamera.front)
    let audioDevice: Observable<TUIAudioPlaybackDevice> = Observable(TUIAudioPlaybackDevice.earpiece)
    let isShowFullScreen: Observable<Bool> = Observable(false)
    let showLargeViewUserId: Observable<String> = Observable("")
    let enableBlurBackground: Observable<Bool> = Observable(false)
    let networkQualityReminder: Observable<NetworkQualityHint> = Observable(NetworkQualityHint.None)
    
    var enableMuteMode: Bool = {
        let enable = UserDefaults.standard.bool(forKey: ENABLE_MUTEMODE_USERDEFAULT)
        return enable
    }()
    
    var enableFloatWindow: Bool = true
    var showVirtualBackgroundButton = false
    var enableIncomingBanner = false
    
    private var timerName: String = ""
}

// MARK: CallObserver
extension TUICallState: TUICallObserver {
    func onError(code: Int32, message: String?) {
        var param: [String: Any] = [:]
        param[EVENT_KEY_CODE] = code
        param[EVENT_KEY_MESSAGE] = message
        let callEvent = TUICallEvent(eventType: .ERROR, event: .ERROR_COMMON, param: param)
        TUICallState.instance.event.value = callEvent
    }
    
    func onCallReceived(callerId: String, calleeIdList: [String], groupId: String?, callMediaType: TUICallMediaType) {
        if (callMediaType == .unknown || calleeIdList.isEmpty) {
            return
        }
        
        if (calleeIdList.count >= MAX_USER) {
            let callEvent = TUICallEvent(eventType: .TIP, event: .USER_EXCEED_LIMIT, param: [:])
            TUICallState.instance.event.value = callEvent
            return
        }
        
        if TUICallKitCommon.checkAuthorizationStatusIsDenied(mediaType: callMediaType) {
            showAuthorizationAlert(mediaType: callMediaType)
            return
        }
        
        let remoteUserIds: [String] = [callerId] + calleeIdList
        User.getUserInfosFromIM(userIDs: remoteUserIds) { remoteUserLists in
            var remoteUsers: [User] = Array()
            for user in remoteUserLists {
                
                if user.id.value == callerId {
                    user.callRole.value = TUICallRole.call
                } else {
                    user.callRole.value = TUICallRole.called
                }
                
                user.callStatus.value = .waiting
                
                if user.id.value != TUICallState.instance.selfUser.value.id.value {
                    if user.id.value == callerId {
                        remoteUsers.insert(user, at: 0)
                    } else {
                        remoteUsers.append(user)
                    }
                }
            }
            TUICallState.instance.remoteUserList.value = remoteUsers
        }
        
        if calleeIdList.count == 1 {
            TUICallState.instance.scene.value = .single
        } else {
            TUICallState.instance.scene.value = .multi
        }
        
        if groupId != nil {
            TUICallState.instance.scene.value = .group
            TUICallState.instance.groupId.value = groupId ?? ""
        }
        TUICallState.instance.mediaType.value = callMediaType
        
        TUICallState.instance.selfUser.value.callRole.value = TUICallRole.called
        
        DispatchQueue.main.async {
            TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.earpiece
                TUICallState.instance.isCameraOpen.value = false
            } else if callMediaType == .video {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.speakerphone
                TUICallState.instance.isCameraOpen.value = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            CallEngineManager.instance.updateVoIPInfo(callerId: callerId, calleeList: calleeIdList, groupId: groupId ?? "")
        }
    }
    
    func onCallCancelled(callerId: String) {
        cleanState()
        CallEngineManager.instance.closeVoIP()
    }
    
    func onKickedOffline() {
        CallEngineManager.instance.hangup()
        cleanState()
    }
    
    func onUserSigExpired() {
        CallEngineManager.instance.hangup()
        cleanState()
    }
    
    func onUserJoin(userId: String) {
        for user in TUICallState.instance.remoteUserList.value where user.id.value == userId {
            user.callStatus.value = TUICallStatus.accept
            return
        }
        
        let remoteUser = User()
        remoteUser.id.value = userId
        remoteUser.callStatus.value = TUICallStatus.accept
        TUICallState.instance.remoteUserList.value.append(remoteUser)
        
        User.getUserInfosFromIM(userIDs: [userId]) { users in
            guard let user = users.first else { return }
            for remote in TUICallState.instance.remoteUserList.value where user.id.value == remote.id.value {
                remote.avatar.value = user.avatar.value
                remote.nickname.value = user.nickname.value
                return
            }
        }
    }
    
    func onUserLeave(userId: String) {
        for index in 0 ..< TUICallState.instance.remoteUserList.value.count
        where TUICallState.instance.remoteUserList.value[index].id.value == userId {
            TUICallState.instance.remoteUserList.value.remove(at: index)
            break
        }
        
        if TUICallState.instance.scene.value == .single {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIWindow.getTopFullscreenWindow()?.makeToast(TUICallKitLocalize(key: "TUICallKit.otherPartyHangup"), duration: 0.6)
            }
        }
        
        if TUICallState.instance.remoteUserList.value.isEmpty {
            cleanState()
        }
        
        let callEvent = TUICallEvent(eventType: .TIP, event: .USER_LEAVE, param: [EVENT_KEY_USER_ID: userId])
        TUICallState.instance.event.value = callEvent
    }
    
    func onUserReject(userId: String) {
        for index in 0 ..< TUICallState.instance.remoteUserList.value.count
        where TUICallState.instance.remoteUserList.value[index].id.value == userId {
            TUICallState.instance.remoteUserList.value.remove(at: index)
            break
        }
        
        if TUICallState.instance.scene.value == .single {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIWindow.getTopFullscreenWindow()?.makeToast(TUICallKitLocalize(key: "TUICallKit.otherPartyReject"), duration: 0.6)
            }
        }
        
        if TUICallState.instance.remoteUserList.value.isEmpty {
            cleanState()
        }
        
        let callEvent = TUICallEvent(eventType: .TIP, event: .USER_REJECT, param: [EVENT_KEY_USER_ID: userId])
        TUICallState.instance.event.value = callEvent
    }
    
    func onUserLineBusy(userId: String) {
        for index in 0 ..< TUICallState.instance.remoteUserList.value.count
        where TUICallState.instance.remoteUserList.value[index].id.value == userId {
            TUICallState.instance.remoteUserList.value.remove(at: index)
            break
        }
        
        if TUICallState.instance.remoteUserList.value.isEmpty {
            cleanState()
        }
        
        let callEvent = TUICallEvent(eventType: .TIP, event: .USER_LINE_BUSY, param: [EVENT_KEY_USER_ID: userId])
        TUICallState.instance.event.value = callEvent
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIWindow.getTopFullscreenWindow()?.makeToast(TUICallKitLocalize(key: "TUICallKit.lineBusy"), duration: 0.6)
        }
    }
    
    func onUserNoResponse(userId: String) {
        for index in 0 ..< TUICallState.instance.remoteUserList.value.count
        where TUICallState.instance.remoteUserList.value[index].id.value == userId {
            TUICallState.instance.remoteUserList.value.remove(at: index)
            break
        }
        
        if TUICallState.instance.scene.value == .single {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIWindow.getTopFullscreenWindow()?.makeToast(TUICallKitLocalize(key: "TUICallKit.otherPartyNoResponse"), duration: 0.6)
            }
        }
        
        let callEvent = TUICallEvent(eventType: .TIP, event: .USER_NO_RESPONSE, param: [EVENT_KEY_USER_ID: userId])
        TUICallState.instance.event.value = callEvent
    }
    
    func onUserVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        for volume in volumeMap {
            for user in TUICallState.instance.remoteUserList.value where user.id.value == volume.key {
                user.playoutVolume.value = volume.value.floatValue
            }
            
            if volume.key == TUICallState.instance.selfUser.value.id.value {
                TUICallState.instance.selfUser.value.playoutVolume.value = volume.value.floatValue
            }
        }
    }
    
    func onUserNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        if networkQualityList.isEmpty {
            return
        }
        
        if TUICallState.instance.scene.value == .single {
            singleSceneNetworkQualityChanged(networkQualityList: networkQualityList)
        } else {
            groupSceneNetworkQualityChanged(networkQualityList: networkQualityList)
        }
    }
    
    func singleSceneNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        var localQuality: TUINetworkQuality = .unknown
        var remoteQuality: TUINetworkQuality = .unknown
        
        for networkQualityInfo in networkQualityList {
            if networkQualityInfo.userId == TUICallState.instance.selfUser.value.id.value {
                localQuality = networkQualityInfo.quality
            }
            remoteQuality = networkQualityInfo.quality
        }
        
        let localIsBadNetwork = checkIsBadNetwork(quality: localQuality)
        let remoteIsBadNetwork = checkIsBadNetwork(quality: remoteQuality)
        var networkQualityHint: NetworkQualityHint
        
        if localIsBadNetwork {
            networkQualityHint = .Local
        } else if !localIsBadNetwork && remoteIsBadNetwork {
            networkQualityHint = .Remote
        } else {
            networkQualityHint = .None
        }
        
        TUICallState.instance.networkQualityReminder.value = networkQualityHint
    }
    
    func groupSceneNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        for networkQualityInfo in networkQualityList {
            let isBadNetwork = checkIsBadNetwork(quality: networkQualityInfo.quality)
            
            for user in TUICallState.instance.remoteUserList.value where user.id.value == networkQualityInfo.userId {
                user.networkQualityReminder.value = isBadNetwork
            }
            
            if networkQualityInfo.userId == TUICallState.instance.selfUser.value.id.value {
                TUICallState.instance.selfUser.value.networkQualityReminder.value = isBadNetwork
            }
        }
    }
    
    func checkIsBadNetwork(quality: TUINetworkQuality) -> Bool {
        return quality == .bad || quality == .vbad || quality == .down
    }
    
    func onUserAudioAvailable(userId: String, isAudioAvailable: Bool) {
        for user in TUICallState.instance.remoteUserList.value where user.id.value == userId {
            user.audioAvailable.value = isAudioAvailable
        }
    }
    
    func onUserVideoAvailable(userId: String, isVideoAvailable: Bool) {
        for user in TUICallState.instance.remoteUserList.value where user.id.value == userId {
            user.videoAvailable.value = isVideoAvailable
        }
    }
    
    func onCallBegin(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole) {
        TUICallState.instance.mediaType.value = callMediaType
        TUICallState.instance.selfUser.value.callRole.value = callRole
        TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.accept
        
        timerName = GCDTimer.start(interval: 1, repeats: true, async: true) {
            TUICallState.instance.timeCount.value += 1
        }
        
        CallEngineManager.instance.setAudioPlaybackDevice(device: TUICallState.instance.audioDevice.value)
        if TUICallState.instance.isMicMute.value == false {
            CallEngineManager.instance.openMicrophone()
        } else {
            CallEngineManager.instance.closeMicrophone()
        }

        showAntiFraudReminder()
        CallEngineManager.instance.callBegin()
    }
    
    func onCallEnd(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole, totalTime: Float) {
        cleanState()
        CallEngineManager.instance.closeVoIP()
    }
    
    func onCallMediaTypeChanged(oldCallMediaType: TUICallMediaType, newCallMediaType: TUICallMediaType) {
        TUICallState.instance.mediaType.value = newCallMediaType
    }
}

// MARK: private method
extension TUICallState {
    func cleanState() {
        TUICallState.instance.isCameraOpen.value = false
        TUICallState.instance.isMicMute.value = false
        
        TUICallState.instance.remoteUserList.value.removeAll()
        
        TUICallState.instance.mediaType.value = .unknown
        TUICallState.instance.timeCount.value = 0
        TUICallState.instance.groupId.value = ""
        
        TUICallState.instance.selfUser.value.callRole.value = TUICallRole.none
        TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus.none
        
        TUICallState.instance.timeCount.value = 0
        TUICallState.instance.isFrontCamera.value = .front
        TUICallState.instance.audioDevice.value = .earpiece
        TUICallState.instance.isShowFullScreen.value = false
        TUICallState.instance.showLargeViewUserId.value = ""
        TUICallState.instance.enableBlurBackground.value = false
        TUICallState.instance.networkQualityReminder.value = .None
        
        GCDTimer.cancel(timerName: timerName) { return }
        
        VideoFactory.instance.viewMap.removeAll()
    }
    
    func getUserIdList() -> [String] {
        var userIdList: [String] = []
        for user in remoteUserList.value {
            userIdList.append(user.id.value)
        }
        return userIdList
    }
    
    func showAuthorizationAlert(mediaType: TUICallMediaType) {
        let statusVideo: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        var deniedType: AuthorizationDeniedType = AuthorizationDeniedType.audio
        
        if mediaType == .video && statusVideo == .denied {
            deniedType = .video
        }
        
        TUICallKitCommon.showAuthorizationAlert(deniedType: deniedType) {
            CallEngineManager.instance.hangup()
        } cancelHandler: {
            CallEngineManager.instance.hangup()
        }
    }
    
    func showAntiFraudReminder() {
        if (TUICore.getService(TUICore_PrivacyService) != nil) {
            TUICore.callService(TUICore_PrivacyService, method: TUICore_PrivacyService_CallKitAntifraudReminderMethod, param: nil)
        }
    }
    
}
