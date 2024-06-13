//
//  RoomVideoFloatViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/7/11.
//

import Foundation
import RTCRoomEngine

protocol RoomVideoFloatViewResponder: NSObject {
    func updateUserStatus(user: UserEntity)
    func updateUserAudioVolume(hasAudio: Bool, volume: Int)
    func makeToast(text: String)
    func showAvatarImageView(isShow: Bool)
}

class RoomVideoFloatViewModel: NSObject {
    var userId: String = ""
    var streamType: TUIVideoStreamType = .cameraStream
    weak var renderView: UIView?
    weak var viewResponder: RoomVideoFloatViewResponder?
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    
    override init() {
        super.init()
        subscribeEngine()
        subLogoutNotification()
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOffLine, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOffLine, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
    }
    
    private func subLogoutNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissFloatViewForLogout),
                                               name: NSNotification.Name.TUILogoutSuccess, object: nil)
    }
    
    private func unsubLogoutNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TUILogoutSuccess, object: nil)
    }
    
    func showRoomMainView() {
        if engineManager.store.isEnteredRoom {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomMainView, param: [:])
        }
    }
    
    func showFloatWindowViewVideo(renderView: UIView?) {
        self.renderView = renderView
        if let userModel = getScreenUserModel() { //If someone is screen sharing, show the screen share first
            showScreenStream(userModel: userModel)
        } else { //Show host without screen sharing
            showOwnerCameraStream()
        }
    }
    
    func getUserEntity(userId: String) -> UserEntity? {
        return engineManager.store.attendeeList.first(where: { $0.userId == userId })
    }
    
    @objc private func dismissFloatViewForLogout() {
        RoomVideoFloatView.dismiss()
    }
    
    deinit {
        engineManager.stopPlayRemoteVideo(userId: userId, streamType: streamType)
        unsubscribeEngine()
        unsubLogoutNotification()
        debugPrint("deinit \(self)")
    }
}

extension RoomVideoFloatViewModel {
    private func getScreenUserModel() -> UserEntity? {
        return engineManager.store.attendeeList.first(where: { $0.hasScreenStream == true })
    }
    
    private func showScreenStream(userModel: UserEntity) {
        let streamType: TUIVideoStreamType = userModel.userId == currentUser.userId ? .cameraStream : .screenStream
        startPlayVideo(userId: userModel.userId, streamType: streamType)
        changePlayingState(userId: userModel.userId, streamType: streamType)
        viewResponder?.updateUserStatus(user: userModel)
        viewResponder?.showAvatarImageView(isShow: false)
    }
    
    private func showOwnerCameraStream() {
        guard let userModel = getUserEntity(userId: roomInfo.ownerId) else { return }
        changePlayingState(userId: userModel.userId, streamType: .cameraStream)
        viewResponder?.updateUserStatus(user: userModel)
        if userModel.hasVideoStream {
            startPlayVideo(userId: userModel.userId, streamType: .cameraStream)
        } else {
            viewResponder?.showAvatarImageView(isShow: true)
        }
    }
    
    private func startPlayVideo(userId: String, streamType: TUIVideoStreamType) {
        if userId == currentUser.userId {
            engineManager.setLocalVideoView(streamType: streamType, view: renderView)
        } else {
            engineManager.setRemoteVideoView(userId: userId, streamType: streamType, view: renderView)
            engineManager.startPlayRemoteVideo(userId: userId, streamType: streamType)
        }
        viewResponder?.showAvatarImageView(isShow: false)
    }
    
    private func stopPlayVideo(userId: String, streamType: TUIVideoStreamType) {
        if userId == currentUser.userId {
            engineManager.setLocalVideoView(streamType: streamType, view: nil)
            return
        }
        engineManager.setRemoteVideoView(userId: userId, streamType: streamType, view: nil)
        guard let userItem = getUserEntity(userId: userId) else { return }
        if streamType == .screenStream, userItem.hasScreenStream {
            engineManager.stopPlayRemoteVideo(userId: userId, streamType: .screenStream)
        } else if streamType == .cameraStream, userItem.hasVideoStream {
            engineManager.stopPlayRemoteVideo(userId: userId, streamType: .cameraStream)
        }
    }
    
    private func changePlayingState(userId: String, streamType: TUIVideoStreamType) {
        self.userId = userId
        self.streamType = streamType
    }
}

extension RoomVideoFloatViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onKickedOutOfRoom, .onRoomDismissed:
            engineManager.destroyEngineManager()
            RoomVideoFloatView.dismiss()
        case .onUserVideoStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            if streamType == .screenStream {
                if hasVideo {
                    stopPlayVideo(userId: roomInfo.ownerId, streamType: .cameraStream)
                    guard let userModel = getUserEntity(userId: userId) else { return }
                    showScreenStream(userModel: userModel)
                } else {
                    stopPlayVideo(userId: self.userId, streamType: .screenStream)
                    showOwnerCameraStream()
                }
                return
            }
            guard getScreenUserModel() == nil else { return } //If someone is screen sharing, don't show the host screen
            guard userId == roomInfo.ownerId else { return }
            if hasVideo {
                startPlayVideo(userId: userId, streamType: streamType)
            } else {
                viewResponder?.showAvatarImageView(isShow: true)
            }
        case .onUserAudioStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            guard userId == self.userId else { return }
                var volume = 0
                if let userModel = getUserEntity(userId: self.userId) {
                    volume = userModel.userVoiceVolume
                }
                viewResponder?.updateUserAudioVolume(hasAudio: hasAudio, volume: volume)
        case .onUserVoiceVolumeChanged:
            guard let volumeNumber = param?[self.userId] as? NSNumber else { return }
            guard let userModel = getUserEntity(userId: self.userId) else { return }
            viewResponder?.updateUserAudioVolume(hasAudio: userModel.hasAudioStream, volume: volumeNumber.intValue)
        case .onKickedOffLine:
            RoomVideoFloatView.dismiss()
        default: break
        }
    }
}

extension RoomVideoFloatViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RoomOwnerChanged:
            guard getScreenUserModel() == nil else { return } //If someone is screen sharing, don't show the host screen
            stopPlayVideo(userId: self.userId, streamType: .cameraStream)
            showOwnerCameraStream()
        default: break
        }
    }
}

