//
//  RoomFloatViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/11.
//

import Foundation
import TUIRoomEngine

protocol RoomFloatViewResponder: NSObject {
    func updateUserStatus(user: UserModel)
    func updateUserAudioVolume(hasAudio: Bool, volume: Int)
    func makeToast(text: String)
    func showAvatarImageView(isShow: Bool)
}

class RoomFloatViewModel: NSObject {
    var userId: String = "" // 现在悬浮窗显示的成员
    var streamType: TUIVideoStreamType = .cameraStream // 现在悬浮窗显示的流
    weak var renderView: UIView?
    weak var viewResponder: RoomFloatViewResponder?
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserModel {
        engineManager.store.currentUser
    }
    
    override init() {
        super.init()
        subscribeEngine()
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
    }
    
    func showRoomMainView() {
        if engineManager.store.isEnteredRoom {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomMainView, param: [:])
        }
    }
    
    func showFloatWindowViewVideo(renderView: UIView?) {
        self.renderView = renderView
        if let userModel = getScreenUserModel() { //如果有人正在进行屏幕共享，优先显示屏幕共享
            showScreenStream(userModel: userModel)
        } else { //没有屏幕共享就显示房主
            showOwnerCameraStream()
        }
    }
    
    deinit {
        engineManager.roomEngine.stopPlayRemoteVideo(userId: userId, streamType: streamType)
        unsubscribeEngine()
        debugPrint("deinit \(self)")
    }
}

extension RoomFloatViewModel {
    private func getScreenUserModel() -> UserModel? {
        return engineManager.store.attendeeList.first(where: { $0.hasScreenStream == true })
    }
    
    private func getUserModel(userId: String) -> UserModel? {
        return engineManager.store.attendeeList.first(where: { $0.userId == userId })
    }
    
    private func showScreenStream(userModel: UserModel) {
        startPlayVideo(userId: userModel.userId, streamType: .screenStream)
        changePlayingState(userId: userModel.userId, streamType: .screenStream)
        viewResponder?.updateUserStatus(user: userModel)
        viewResponder?.showAvatarImageView(isShow: false)
    }
    
    private func showOwnerCameraStream() {
        guard let userModel = getUserModel(userId: roomInfo.ownerId) else { return }
        userModel.userRole = .roomOwner
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
            engineManager.roomEngine.setLocalVideoView(streamType: streamType, view: renderView)
        } else {
            engineManager.roomEngine.setRemoteVideoView(userId: userId, streamType: streamType, view: renderView)
            engineManager.roomEngine.startPlayRemoteVideo(userId: userId, streamType: streamType, onPlaying: { _ in
            }, onLoading: { _ in
            }, onError: { _, _, _ in
            })
        }
        viewResponder?.showAvatarImageView(isShow: false)
    }
    
    //清理被占用的view
    private func resetVideoView(userId: String, streamType: TUIVideoStreamType) {
        if userId != currentUser.userId {
            engineManager.roomEngine.setRemoteVideoView(userId: userId, streamType: streamType, view: nil)
        } else {
            engineManager.roomEngine.setLocalVideoView(streamType: streamType, view: nil)
        }
    }
    
    private func changePlayingState(userId: String, streamType: TUIVideoStreamType) {
        self.userId = userId
        self.streamType = streamType
    }
}

extension RoomFloatViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onKickedOutOfRoom, .onRoomDismissed:
            engineManager.destroyEngineManager()
            RoomFloatView.dismiss()
        case .onUserRoleChanged:
            guard let userRole = param?["userRole"] as? TUIRole else { return }
            guard let userId = param?["userId"] as? String else { return }
            guard userRole == .roomOwner else { return }
            roomInfo.ownerId = userId
            guard getScreenUserModel() == nil else { return } //如果有人正在进行屏幕共享，不显示房主画面
            resetVideoView(userId: self.userId, streamType: .cameraStream)
            showOwnerCameraStream()
        case .onUserVideoStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            if streamType == .screenStream {
                if hasVideo {
                    resetVideoView(userId: roomInfo.ownerId, streamType: .cameraStream)
                    guard let userModel = getUserModel(userId: userId) else { return }
                    showScreenStream(userModel: userModel)
                } else {
                    resetVideoView(userId: self.userId, streamType: .screenStream)
                    showOwnerCameraStream()
                }
                return
            }
            guard getScreenUserModel() == nil else { return } //如果有人在进行屏幕共享，不显示房主画面
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
                if let userModel = getUserModel(userId: self.userId) {
                    volume = userModel.volume
                }
                viewResponder?.updateUserAudioVolume(hasAudio: hasAudio, volume: volume)
        case .onUserVoiceVolumeChanged:
            guard let volumeNumber = param?[self.userId] as? NSNumber else { return }
            guard let userModel = getUserModel(userId: self.userId) else { return }
            viewResponder?.updateUserAudioVolume(hasAudio: userModel.hasAudioStream, volume: volumeNumber.intValue)
        default: break
        }
    }
}

