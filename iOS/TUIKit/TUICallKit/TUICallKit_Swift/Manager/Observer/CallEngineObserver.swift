//
//  TUICallState.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import TUICore
import RTCRoomEngine
import RTCCommon
import AVFoundation

class CallEngineObserver: NSObject, TUICallObserver {
    
    static let shared = CallEngineObserver()
    
    var timer: String?
    
    func onError(code: Int32, message: String?) {
        Logger.info("CallEngineObserver->onError. code:\(code), message:\(message ?? "")")
        if let message = message {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: "code:\(code), message:\(message)")
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: "code:\(code)")
        }
    }
    
    func onCallReceived(_ callId: String, callerId: String, calleeIdList: [String], mediaType: TUICallMediaType, info: TUICallObserverExtraInfo) {
        Logger.info("CallEngineObserver->onCallReceived. callId:\(callId), callerId:\(callerId), calleeIdList:\(calleeIdList), mediaType:\(mediaType), info:\(info)")
        if (mediaType == .unknown || calleeIdList.isEmpty) {
            return
        }
        
        if (calleeIdList.count >= MAX_USER) {
            return
        }
                
        if calleeIdList.count == 1 {
            CallManager.shared.viewState.callingViewType.value = .one2one
        } else {
            CallManager.shared.viewState.callingViewType.value = .multi
        }
        
        if !info.chatGroupId.isEmpty {
            CallManager.shared.viewState.callingViewType.value = .multi
            CallManager.shared.callState.chatGroupId.value = info.chatGroupId
        }
        CallManager.shared.callState.mediaType.value = mediaType
        CallManager.shared.userState.selfUser.callRole.value = TUICallRole.called
        CallManager.shared.userState.selfUser.callStatus.value = TUICallStatus.waiting
        if mediaType == .audio {
            CallManager.shared.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
            CallManager.shared.mediaState.isCameraOpened.value = false
        } else if mediaType == .video {
            CallManager.shared.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.speakerphone
            CallManager.shared.mediaState.isCameraOpened.value = true
        }
        
                
        let callerIdUser = User()
        callerIdUser.id.value = callerId
        callerIdUser.callStatus.value = .waiting
        callerIdUser.callRole.value = .call
        CallManager.shared.userState.remoteUserList.value.append(callerIdUser)
        
        var remoteCalleeIdList = calleeIdList
        if let selfUserIndex = remoteCalleeIdList.firstIndex(of: CallManager.shared.userState.selfUser.id.value) {
            remoteCalleeIdList.remove(at: selfUserIndex)
        }
        
        for userId in remoteCalleeIdList {
            let remoteUser = User()
            remoteUser.id.value = userId
            remoteUser.callStatus.value = .waiting
            remoteUser.callRole.value = .called
            CallManager.shared.userState.remoteUserList.value.append(remoteUser)
        }

        let remoteUserIds: [String] = [callerId] + remoteCalleeIdList
        UserManager.getUserInfosFromIM(userIDs: remoteUserIds) { mInviteeList in
            for remoteUser in CallManager.shared.userState.remoteUserList.value {
                for imUserInfo in mInviteeList {
                    if remoteUser.id.value == imUserInfo.id.value {
                        remoteUser.nickname.value = imUserInfo.nickname.value
                        remoteUser.remark.value = imUserInfo.remark.value
                        remoteUser.avatar.value = imUserInfo.avatar.value
                    }
                }
            }

            if CallManager.shared.userState.selfUser.callStatus.value != .none {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
            }
        }
        
        CallManager.shared.updateVoIPInfo(callerId: callerId, calleeList: calleeIdList, groupId: info.chatGroupId ?? "", mediaType: mediaType)
    }
    
    func onCallNotConnected(callId: String, mediaType: TUICallMediaType, reason: TUICallEndReason, userId: String, info: TUICallObserverExtraInfo) {
        Logger.info("CallEngineObserver->onCallNotConnected. callId:\(callId), mediaType:\(mediaType), reason:\(reason), userId:\(userId), info:\(info)")
        CallManager.shared.resetState()
        CallManager.shared.closeVoIP()
    }
    
    func onUserInviting(userId: String) {
        Logger.info("CallEngineObserver->onUserInviting. userId:\(userId)")
        if CallManager.shared.userState.selfUser.id.value == userId  { return }

        guard !CallManager.shared.userState.remoteUserList.value.contains(where: { $0.id.value == userId }) else {
            return
        }
        
        let remoteUser = User()
        remoteUser.id.value = userId
        remoteUser.callStatus.value = TUICallStatus.accept
        CallManager.shared.userState.remoteUserList.value.append(remoteUser)
        
        UserManager.getUserInfosFromIM(userIDs: [userId]) { users in
            guard let user = users.first else { return }
            for remote in CallManager.shared.userState.remoteUserList.value where user.id.value == remote.id.value {
                remote.avatar.value = user.avatar.value
                remote.nickname.value = user.nickname.value
                return
            }
        }
    }
    
    func onKickedOffline() {
        Logger.info("CallEngineObserver->onKickedOffline")
        CallManager.shared.hangup() { } fail: { code, message in }
        CallManager.shared.resetState()
    }
    
    func onUserSigExpired() {
        Logger.info("CallEngineObserver->onUserSigExpired")
        CallManager.shared.hangup() { } fail: { code, message in }
        CallManager.shared.resetState()
    }
    
    func onUserJoin(userId: String) {
        Logger.info("CallEngineObserver->onUserJoin. userId:\(userId)")
        guard !userId.contains(AI_TRANSLATION_ROBOT) else { return }
        for user in CallManager.shared.userState.remoteUserList.value where user.id.value == userId {
            user.callStatus.value = TUICallStatus.accept
            return
        }
        
        let remoteUser = User()
        remoteUser.id.value = userId
        remoteUser.callStatus.value = TUICallStatus.accept
        CallManager.shared.userState.remoteUserList.value.append(remoteUser)
        
        UserManager.getUserInfosFromIM(userIDs: [userId]) { users in
            guard let user = users.first else { return }
            for remote in CallManager.shared.userState.remoteUserList.value where user.id.value == remote.id.value {
                remote.avatar.value = user.avatar.value
                remote.nickname.value = user.nickname.value
                return
            }
        }
    }
    
    func onUserLeave(userId: String) {
        Logger.info("CallEngineObserver->onUserLeave. userId:\(userId)")
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: TUICallKitLocalize(key: "TUICallKit.otherPartyHangup") ?? "")
        }
        
        for index in 0 ..< CallManager.shared.userState.remoteUserList.value.count
        where CallManager.shared.userState.remoteUserList.value[index].id.value == userId {
            VideoFactory.shared.removeVideoView(user: CallManager.shared.userState.remoteUserList.value[index])
            CallManager.shared.userState.remoteUserList.value.remove(at: index)
            break
        }
        
        if CallManager.shared.userState.remoteUserList.value.isEmpty {
            CallManager.shared.resetState()
        }
    }
    
    func onUserReject(userId: String) {
        Logger.info("CallEngineObserver->onUserReject. userId:\(userId)")
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: TUICallKitLocalize(key: "TUICallKit.otherPartyReject") ?? "")
        }
        
        for index in 0 ..< CallManager.shared.userState.remoteUserList.value.count
        where CallManager.shared.userState.remoteUserList.value[index].id.value == userId {
            VideoFactory.shared.removeVideoView(user: CallManager.shared.userState.remoteUserList.value[index])
            CallManager.shared.userState.remoteUserList.value.remove(at: index)
            break
        }
        
        if CallManager.shared.userState.remoteUserList.value.isEmpty {
            CallManager.shared.resetState()
        }
    }
    
    func onUserLineBusy(userId: String) {
        Logger.info("CallEngineObserver->onUserLineBusy. userId:\(userId)")
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: TUICallKitLocalize(key: "TUICallKit.lineBusy") ?? "")
        }
        
        for index in 0 ..< CallManager.shared.userState.remoteUserList.value.count
        where CallManager.shared.userState.remoteUserList.value[index].id.value == userId {
            VideoFactory.shared.removeVideoView(user: CallManager.shared.userState.remoteUserList.value[index])
            CallManager.shared.userState.remoteUserList.value.remove(at: index)
            break
        }
        
        if CallManager.shared.userState.remoteUserList.value.isEmpty {
            CallManager.shared.resetState()
        }
    }
    
    func onUserNoResponse(userId: String) {
        Logger.info("CallEngineObserver->onUserNoResponse. userId:\(userId)")
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST), object: TUICallKitLocalize(key: "TUICallKit.otherPartyNoResponse") ?? "")
        }
        
        for index in 0 ..< CallManager.shared.userState.remoteUserList.value.count
        where CallManager.shared.userState.remoteUserList.value[index].id.value == userId {
            VideoFactory.shared.removeVideoView(user: CallManager.shared.userState.remoteUserList.value[index])
            CallManager.shared.userState.remoteUserList.value.remove(at: index)
            break
        }
    }
    
    func onUserVoiceVolumeChanged(volumeMap: [String : NSNumber]) {
        for volume in volumeMap {
            for user in CallManager.shared.userState.remoteUserList.value where user.id.value == volume.key {
                user.playoutVolume.value = volume.value.floatValue
            }
            
            if volume.key == CallManager.shared.userState.selfUser.id.value {
                CallManager.shared.userState.selfUser.playoutVolume.value = volume.value.floatValue
            }
        }
    }
    
    func onUserNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        if networkQualityList.isEmpty {
            return
        }
        
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            singleSceneNetworkQualityChanged(networkQualityList: networkQualityList)
        } else {
            groupSceneNetworkQualityChanged(networkQualityList: networkQualityList)
        }
    }
    
    func singleSceneNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        var localQuality: TUINetworkQuality = .unknown
        var remoteQuality: TUINetworkQuality = .unknown
        
        for networkQualityInfo in networkQualityList {
            if networkQualityInfo.userId == CallManager.shared.userState.selfUser.id.value {
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
        
        CallManager.shared.callState.networkQualityReminder.value = networkQualityHint
    }
    
    func groupSceneNetworkQualityChanged(networkQualityList: [TUINetworkQualityInfo]) {
        for networkQualityInfo in networkQualityList {
            let isBadNetwork = checkIsBadNetwork(quality: networkQualityInfo.quality)
            
            for user in CallManager.shared.userState.remoteUserList.value where user.id.value == networkQualityInfo.userId {
                user.networkQualityReminder.value = isBadNetwork
            }
            
            if networkQualityInfo.userId == CallManager.shared.userState.selfUser.id.value {
                CallManager.shared.userState.selfUser.networkQualityReminder.value = isBadNetwork
            }
        }
    }
    
    func checkIsBadNetwork(quality: TUINetworkQuality) -> Bool {
        return quality == .bad || quality == .veryBad || quality == .down
    }
    
    func onUserAudioAvailable(userId: String, isAudioAvailable: Bool) {
        Logger.info("CallEngineObserver->onUserAudioAvailable. userId:\(userId), isAudioAvailable:\(isAudioAvailable)")
        for user in CallManager.shared.userState.remoteUserList.value where user.id.value == userId {
            user.audioAvailable.value = isAudioAvailable
        }
    }
    
    func onUserVideoAvailable(userId: String, isVideoAvailable: Bool) {
        Logger.info("CallEngineObserver->onUserVideoAvailable. userId:\(userId), isVideoAvailable:\(isVideoAvailable)")
        for user in CallManager.shared.userState.remoteUserList.value where user.id.value == userId {
            user.videoAvailable.value = isVideoAvailable
        }
    }
    
    func onCallBegin(callId: String, mediaType: TUICallMediaType, info: TUICallObserverExtraInfo) {
        Logger.info("CallEngineObserver->onCallBegin. callId:\(callId), mediaType:\(mediaType), info:\(info)")
        CallManager.shared.callState.mediaType.value = mediaType
        CallManager.shared.userState.selfUser.callRole.value = info.role
        CallManager.shared.userState.selfUser.callStatus.value = TUICallStatus.accept
        CallManager.shared.callState.chatGroupId.value = info.chatGroupId
        
        timer = GCDTimer.start(interval: 1, repeats: true, async: true) {
            CallManager.shared.callState.callDurationCount.value += 1
        }
        
        CallManager.shared.setAudioPlaybackDevice(device: CallManager.shared.mediaState.audioPlayoutDevice.value)
        if CallManager.shared.mediaState.isMicrophoneMuted.value == false {
            CallManager.shared.openMicrophone() { } fail: { code, message in }
        } else {
            CallManager.shared.closeMicrophone()
        }
        
        showAntiFraudReminder()
        CallManager.shared.callBegin()
    }
    
    func onCallEnd(callId: String,
                   mediaType: TUICallMediaType,
                   reason: TUICallEndReason,
                   userId: String,
                   totalTime: Float,
                   info: TUICallObserverExtraInfo) {
        Logger.info("CallEngineObserver->onCallEnd. callId:\(callId), mediaType:\(mediaType), reason:\(reason), userId:\(userId), totalTime:\(totalTime), info:\(info)")
        CallManager.shared.resetState()
        GCDTimer.cancel(timerName: timer ?? "") { return }
        CallManager.shared.closeVoIP()
    }
    
    func onCallMediaTypeChanged(oldCallMediaType: TUICallMediaType, newCallMediaType: TUICallMediaType) {
        Logger.info("CallEngineObserver->onCallMediaTypeChanged. oldCallMediaType:\(oldCallMediaType), newCallMediaType:\(newCallMediaType)")
        CallManager.shared.callState.mediaType.value = newCallMediaType
    }
    
    // MARK: private method
    private func showAntiFraudReminder() {
        Logger.info("CallEngineObserver->showAntiFraudReminder")
        if (TUICore.getService(TUICore_PrivacyService) != nil) {
            TUICore.callService(TUICore_PrivacyService, method: TUICore_PrivacyService_CallKitAntifraudReminderMethod, param: nil)
        }
    }
}
