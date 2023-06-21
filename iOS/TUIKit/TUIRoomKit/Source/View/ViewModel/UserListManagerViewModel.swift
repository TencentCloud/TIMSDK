//
//  UserListManagerViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/2/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

protocol UserListManagerViewEventResponder: AnyObject {
    func updateUI(items: [ButtonItemData])
    func makeToast(text: String)
}

class UserListManagerViewModel: NSObject {
    enum userType {
        case currentUserType //自己
        case otherUserType   //自由发言房间其他用户
        case onSeatUserType  //举手发言房间已经上麦用户
        case offSeatUserType //举手发言房间已经下麦用户
    }
    var userId: String = ""
    let timeoutNumber: Double = 30
    private(set) var otherUserItems: [ButtonItemData] = []//其他用户viewItem
    private(set) var currentUserItems: [ButtonItemData] = []
    private(set) var onSeatItems: [ButtonItemData] = []//已经上麦的用户viewItem
    private(set) var offSeatItems: [ButtonItemData] = []//没有上麦的用户viewItem
    weak var viewResponder: UserListManagerViewEventResponder?
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserModel {
        engineManager.store.currentUser
    }
    var attendeeList: [UserModel] {
        engineManager.store.attendeeList
    }
    
    override init() {
        super.init()
        self.createUserItem()
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
    }
    
    func createUserItem() {
        //静音（本地静音）
        let muteLocalAudioItem = ButtonItemData()
        muteLocalAudioItem.normalTitle = .muteText
        muteLocalAudioItem.normalIcon = "room_unMute_audio"
        muteLocalAudioItem.selectedTitle = .unmuteText
        muteLocalAudioItem.selectedIcon = "room_mute_audio"
        muteLocalAudioItem.resourceBundle = tuiRoomKitBundle()
        muteLocalAudioItem.buttonType = .muteAudioItemType
        muteLocalAudioItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteLocalAudioAction(sender: button)
        }
        currentUserItems.append(muteLocalAudioItem)
        //禁画（本地禁画）
        let muteLocalVideoItem = ButtonItemData()
        muteLocalVideoItem.normalTitle = .closeVideoText
        muteLocalVideoItem.normalIcon = "room_unMute_video"
        muteLocalVideoItem.selectedTitle = .openVideoText
        muteLocalVideoItem.selectedIcon = "room_mute_video"
        muteLocalVideoItem.resourceBundle = tuiRoomKitBundle()
        muteLocalVideoItem.buttonType = .muteVideoItemType
        muteLocalVideoItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteLocalVideoAction(sender: button)
        }
        currentUserItems.append(muteLocalVideoItem)
        //静音（禁音其他用户）
        let muteAudioItem = ButtonItemData()
        muteAudioItem.normalTitle = .muteText
        muteAudioItem.normalIcon = "room_unMute_audio"
        muteAudioItem.selectedTitle = .unmuteText
        muteAudioItem.selectedIcon = "room_mute_audio"
        muteAudioItem.resourceBundle = tuiRoomKitBundle()
        muteAudioItem.buttonType = .muteAudioItemType
        muteAudioItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteAudioAction(sender: button)
        }
        otherUserItems.append(muteAudioItem)
        onSeatItems.append(muteAudioItem)
        //禁画（禁画其他用户）
        let muteVideoItem = ButtonItemData()
        muteVideoItem.normalTitle = .closeVideoText
        muteVideoItem.normalIcon = "room_unMute_video"
        muteVideoItem.selectedTitle = .openVideoText
        muteVideoItem.selectedIcon = "room_mute_video"
        muteVideoItem.resourceBundle = tuiRoomKitBundle()
        muteVideoItem.buttonType = .muteVideoItemType
        muteVideoItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteVideoAction(sender: button)
        }
        otherUserItems.append(muteVideoItem)
        onSeatItems.append(muteVideoItem)
        //邀请上台
        let inviteSeatItem = ButtonItemData()
        inviteSeatItem.normalTitle = .inviteSeatText
        inviteSeatItem.normalIcon = "room_invite_seat"
        inviteSeatItem.selectedTitle = .inviteSeatText
        inviteSeatItem.selectedIcon = "room_invite_seat"
        inviteSeatItem.resourceBundle = tuiRoomKitBundle()
        inviteSeatItem.buttonType = .inviteSeatItemType
        inviteSeatItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.inviteSeatAction(sender: button)
        }
        offSeatItems.append(inviteSeatItem)
        //转交主持人
        let changeHostItem = ButtonItemData()
        changeHostItem.normalTitle = .changeHostText
        changeHostItem.normalIcon = "room_change_host"
        changeHostItem.selectedTitle = .changeHostText
        changeHostItem.selectedIcon = "room_change_host"
        changeHostItem.resourceBundle = tuiRoomKitBundle()
        changeHostItem.buttonType = .changeHostItemType
        changeHostItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.changeHostAction(sender: button)
        }
        otherUserItems.append(changeHostItem)
        onSeatItems.append(changeHostItem)
        offSeatItems.append(changeHostItem)
        //禁言
        let muteMessageItem = ButtonItemData()
        muteMessageItem.normalTitle = .muteMessageText
        muteMessageItem.normalIcon = "room_mute_message"
        muteMessageItem.selectedTitle = .unMuteMessageText
        muteMessageItem.selectedIcon = "room_unMute_message"
        muteMessageItem.resourceBundle = tuiRoomKitBundle()
        muteMessageItem.buttonType = .muteMessageItemType
        muteMessageItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteMessageAction(sender: button)
        }
        otherUserItems.append(muteMessageItem)
        offSeatItems.append(muteMessageItem)
        //请下台
        let stepDownSeatItem = ButtonItemData()
        stepDownSeatItem.normalTitle = .stepDownSeatText
        stepDownSeatItem.normalIcon = "room_step_down_seat"
        stepDownSeatItem.selectedTitle = .stepDownSeatText
        stepDownSeatItem.selectedIcon = "room_step_down_seat"
        stepDownSeatItem.resourceBundle = tuiRoomKitBundle()
        stepDownSeatItem.buttonType = .stepDownSeatItemType
        stepDownSeatItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.kickRemoteUserOffSeat(sender: button)
        }
        onSeatItems.append(stepDownSeatItem)
        //踢出房间
        let kickOutItem = ButtonItemData()
        kickOutItem.normalTitle = .kickOutRoomText
        kickOutItem.normalIcon = "room_kickOut_room"
        kickOutItem.selectedTitle = .kickOutRoomText
        kickOutItem.selectedIcon = "room_kickOut_room"
        kickOutItem.resourceBundle = tuiRoomKitBundle()
        kickOutItem.buttonType = .kickOutItemType
        kickOutItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.kickOutAction(sender: button)
        }
        otherUserItems.append(kickOutItem)
        onSeatItems.append(kickOutItem)
        offSeatItems.append(kickOutItem)
    }
    
    func muteLocalAudioAction(sender: UIButton) {
        if currentUser.hasAudioStream {
            engineManager.roomEngine.closeLocalMicrophone()
            engineManager.roomEngine.stopPushLocalAudio()
            return
        }
        //如果房主全体静音，房间成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userRole != .roomOwner {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
           return
        }
        // 直接打开本地的麦克风
        let openLocalMicrophoneBlock = { [weak self] in
            guard let self = self else { return }
            self.engineManager.roomEngine.openLocalMicrophone(self.engineManager.store.audioSetting.audioQuality) { [weak self] in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalAudio()
            } onError: { code, message in
                debugPrint("openLocalMicrophone,code:\(code), message:\(message)")
            }
        }
        //打开本地的麦克风需要进行申请
        let applyToAdminToOpenLocalDeviceBlock = { [weak self] in
            guard let self = self else { return }
            self.engineManager.roomEngine.applyToAdminToOpenLocalDevice(device: .microphone, timeout: self.timeoutNumber) {  [weak self] _, _ in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalAudio()
            } onRejected: { _, _, _ in
                //todo
            } onCancelled: { _, _ in
                //todo
            } onTimeout: { _, _ in
                //todo
            }
        }
        switch roomInfo.speechMode {
        case .freeToSpeak:
            openLocalMicrophoneBlock()
        case .applySpeakAfterTakingSeat:
            if currentUser.isOnSeat {
                openLocalMicrophoneBlock()
            } else {
                viewResponder?.makeToast(text: .muteAudioSeatReasonText)
            }
        case .applyToSpeak:
            applyToAdminToOpenLocalDeviceBlock()
        @unknown default:
            break
        }
    }
    
    func muteLocalVideoAction(sender: UIButton) {
        if currentUser.hasVideoStream {
            engineManager.roomEngine.closeLocalCamera()
            engineManager.roomEngine.stopPushLocalVideo()
            return
        }
        //如果房主全体禁画，房间成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userRole != .roomOwner {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
           return
        }
        // 直接打开本地的摄像头
        let openLocalCameraBlock = { [weak self] in
            guard let self = self else { return }
            // FIXME: - 打开摄像头前需要先设置一个view
            self.engineManager.roomEngine.setLocalVideoView(streamType: .cameraStream, view: UIView())
            self.engineManager.roomEngine.openLocalCamera(isFront: self.engineManager.store.videoSetting.isFrontCamera, quality:
                                                            self.engineManager.store.videoSetting.videoQuality) { [weak self] in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalVideo()
            } onError: { code, message in
                debugPrint("openLocalCamera,code:\(code),message:\(message)")
            }
        }
        //打开本地的摄像头需要向房主进行申请
        let applyToAdminToOpenLocalDeviceBlock = { [weak self] in
            guard let self = self else { return }
            self.engineManager.roomEngine.applyToAdminToOpenLocalDevice(device: .camera, timeout: self.timeoutNumber) {  [weak self] _, _ in
                guard let self = self else { return }
                self.engineManager.roomEngine.startPushLocalVideo()
            } onRejected: { _, _, _ in
                //todo
            } onCancelled: { _, _ in
                //todo
            } onTimeout: { _, _ in
                //todo
            }
        }
        switch roomInfo.speechMode {
        case .freeToSpeak:
            openLocalCameraBlock()
        case .applySpeakAfterTakingSeat:
            if currentUser.isOnSeat {
                openLocalCameraBlock()
            } else {
                viewResponder?.makeToast(text: .muteVideoSeatReasonText)
            }
        case .applyToSpeak:
            applyToAdminToOpenLocalDeviceBlock()
        @unknown default:
            break
        }
    }
    
    func muteAudioAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let roomEngine = engineManager.roomEngine
        let mute = userInfo.hasAudioStream
        if mute {
            roomEngine.closeRemoteDeviceByAdmin(userId: userId, device: .microphone) {
                sender.isSelected = !sender.isSelected
                userInfo.hasAudioStream = !mute
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }
        } else {
            roomEngine.openRemoteDeviceByAdmin(userId: userId, device: .microphone, timeout: 30, onAccepted: { [weak self] _, _ in
                guard let self = self else { return }
                sender.isSelected = !sender.isSelected
                self.viewResponder?.makeToast(text: .muteAudioSuccessToastText)
            }, onRejected: { [weak self] _, _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }, onCancelled: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }
        }
    }
    
    func muteVideoAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let roomEngine = engineManager.roomEngine
        let mute = userInfo.hasVideoStream
        if mute {
            roomEngine.closeRemoteDeviceByAdmin(userId: userId, device: .camera) { [weak self] in
                guard let _ = self else { return }
                userInfo.hasVideoStream = !mute
                sender.isSelected = !sender.isSelected
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }
        } else {
            roomEngine.openRemoteDeviceByAdmin(userId: userId, device: .camera, timeout: 30, onAccepted: { [weak self] _, _ in
                guard let self = self else { return }
                sender.isSelected = !sender.isSelected
                self.viewResponder?.makeToast(text: .muteVideoSuccessToastText)
            }, onRejected: { [weak self] _, _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }, onCancelled: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }
        }
    }
    
    func inviteSeatAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.roomEngine.takeUserOnSeatByAdmin(-1, userId: userId, timeout: 30) { _, _ in
            //todo
        } onRejected: { _, _, _ in
            //todo
        } onCancelled: { _, _ in
            //todo
        } onTimeout: { _, _ in
            //todo
        } onError: { _, _, _, _ in
            //todo
        }
    }
    
    func changeHostAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let roomEngine = engineManager.roomEngine
        roomEngine.changeUserRole(userId: userId, role: .roomOwner) {
            debugPrint("转交主持人,success")
        } onError: { code, message in
            debugPrint("转交主持人，code,message")
        }
    }
    
    func muteMessageAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let isDisable = !userInfo.isMuteMessage
        engineManager.roomEngine.disableSendingMessageByAdmin(userId: userId, isDisable: isDisable) {
        } onError: { code, message in
            debugPrint("disableSendingMessageByAdmin,code:\(code),message:\(message)")
        }
    }
    
    func kickRemoteUserOffSeat(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.roomEngine.kickUserOffSeatByAdmin(-1, userId: userId) {
            //todo
        } onError: { code, message in
            //todo
        }
    }
    
    func kickOutAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.roomEngine.kickRemoteUserOutOfRoom(userId) {
            //todo
        } onError: { code, message in
            //todo
        }
    }
    
    //根据用户的状态更新item数组
    func updateUserItem() {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        updateItem(buttonType: .muteAudioItemType, muted: !userInfo.hasAudioStream)
        updateItem(buttonType: .muteVideoItemType, muted: !userInfo.hasVideoStream)
        updateItem(buttonType: .muteMessageItemType, muted: userInfo.isMuteMessage)
    }
    
    func updateItem(buttonType: ButtonItemData.ButtonType, muted: Bool) {
        let userType = getUserType(userId: userId)
        switch userType {
        case .currentUserType:
            guard let currentItem = currentUserItems.first(where: { $0.buttonType == buttonType }) else { return }
            currentItem.isSelect = muted
            viewResponder?.updateUI(items: currentUserItems)
        case .otherUserType:
            guard let otherItem = otherUserItems.first(where: { $0.buttonType == buttonType }) else { return }
            otherItem.isSelect = muted
            viewResponder?.updateUI(items: otherUserItems)
        case .onSeatUserType:
            guard let onSeatItem = onSeatItems.first(where: { $0.buttonType == buttonType }) else { return }
            onSeatItem.isSelect = muted
            viewResponder?.updateUI(items: onSeatItems)
        case .offSeatUserType:
            guard let offSeatItem = offSeatItems.first(where: { $0.buttonType == buttonType }) else { return }
            offSeatItem.isSelect = muted
            viewResponder?.updateUI(items: offSeatItems)
        default: break
        }
    }
    
    func getUserType(userId: String) -> userType? {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return nil }
        switch roomInfo.speechMode {
        case .freeToSpeak:
            if userId == currentUser.userId {
                return .currentUserType
            } else {
                return .otherUserType
            }
        case .applySpeakAfterTakingSeat:
            if userId == currentUser.userId {
                return.currentUserType
            } else {
                if userInfo.isOnSeat {
                    return .onSeatUserType
                } else {
                    return .offSeatUserType
                }
            }
        default: break
        }
        return nil
    }
    
    func backBlockAction(sender: UIView) {
        sender.isHidden = true
    }
}

extension UserListManagerViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        if name == .onUserAudioStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            if userId == self.userId {
                updateItem(buttonType: .muteAudioItemType, muted: !hasAudio)
            }
        }
        if name == .onUserVideoStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            if userId == self.userId && streamType == .cameraStream {
                updateItem(buttonType: .muteVideoItemType, muted: !hasVideo)
            }
        }
        if name == .onSendMessageForUserDisableChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let muted = param?["muted"] as? Bool else { return }
            if userId == self.userId {
                updateItem(buttonType: .muteMessageItemType, muted: muted)
            }
        }
    }
}

private extension String {
    static var muteAudioErrorToastText: String {
        localized("TUIRoom.mute.audio.error.toast")
    }
    static var muteAudioSuccessToastText: String {
        localized("TUIRoom.mute.audio.success.toast")
    }
    static var muteVideoErrorToastText: String {
        localized("TUIRoom.mute.video.error.toast")
    }
    static var muteVideoSuccessToastText: String {
        localized("TUIRoom.mute.video.success.toast")
    }
    static var muteText: String {
        localized("TUIRoom.mute")
    }
    static var unmuteText: String {
        localized("TUIRoom.unmute")
    }
    static var openVideoText: String {
        localized("TUIRoom.open.video")
    }
    static var closeVideoText: String {
        localized("TUIRoom.close.video")
    }
    static var changeHostText: String {
        localized("TUIRoom.change.host")
    }
    static var muteMessageText: String {
        localized("TUIRoom.mute.message")
    }
    static var unMuteMessageText: String {
        localized("TUIRoom.unmute.message")
    }
    static var kickOutRoomText: String {
        localized("TUIRoom.kick")
    }
    static var stepDownSeatText: String {
        localized("TUIRoom.step.down.seat")
    }
    static var inviteSeatText: String {
        localized("TUIRoom.invite.seat")
    }
    static var muteAudioSeatReasonText: String {
        localized("TUIRoom.mute.audio.seat.reason")
    }
    static var muteVideoSeatReasonText: String {
        localized("TUIRoom.mute.video.seat.reason")
    }
    static var muteAudioRoomReasonText: String {
        localized("TUIRoom.mute.audio.room.reason")
    }
    static var muteVideoRoomReasonText: String {
        localized("TUIRoom.mute.video.room.reason")
    }
}
