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
    func showTransferredRoomOwnerAlert()
    func showKickOutAlert(title: String, sureAction: (() ->())?)
    func setUserListManagerViewHidden(isHidden: Bool)
}

class UserListManagerViewModel: NSObject {
    enum userType {
        case currentUserType //自己
        case otherUserType   //自由发言房间其他用户
        case onSeatUserType  //举手发言房间已经上麦用户
        case offSeatUserType //举手发言房间已经下麦用户
    }
    var userId: String = ""
    var userName: String = ""
    let timeoutNumber: Double = 10
    private(set) var otherUserItems: [ButtonItemData] = []//其他用户viewItem
    private(set) var currentUserItems: [ButtonItemData] = []
    private(set) var onSeatItems: [ButtonItemData] = []//已经上麦的用户viewItem
    private(set) var offSeatItems: [ButtonItemData] = []//没有上麦的用户viewItem
    weak var viewResponder: UserListManagerViewEventResponder?
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    var attendeeList: [UserEntity] {
        engineManager.store.attendeeList
    }
    private var hasOpenCameraInvite = false
    private var hasOpenMicrophoneInvite = false
    
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
        muteLocalAudioItem.hasLineView = true
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
        muteLocalVideoItem.hasLineView = true
        muteLocalVideoItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteLocalVideoAction(sender: button)
        }
        currentUserItems.append(muteLocalVideoItem)
        //静音（禁音其他用户）
        let muteAudioItem = ButtonItemData()
        muteAudioItem.normalTitle = .muteText
        muteAudioItem.normalIcon = "room_unMute_audio"
        muteAudioItem.selectedTitle = .requestOpenAudioText
        muteAudioItem.selectedIcon = "room_mute_audio"
        muteAudioItem.resourceBundle = tuiRoomKitBundle()
        muteAudioItem.buttonType = .muteAudioItemType
        muteAudioItem.hasLineView = true
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
        muteVideoItem.selectedTitle = .requestOpenVideoText
        muteVideoItem.selectedIcon = "room_mute_video"
        muteVideoItem.resourceBundle = tuiRoomKitBundle()
        muteVideoItem.buttonType = .muteVideoItemType
        muteVideoItem.hasLineView = true
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
        inviteSeatItem.hasLineView = true
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
        changeHostItem.hasLineView = true
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
        muteMessageItem.hasLineView = true
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
        stepDownSeatItem.hasLineView = true
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
        kickOutItem.hasLineView = true
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
            engineManager.muteLocalAudio()
            return
        }
        //如果房主全体静音，房间成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开麦克风
        if roomInfo.speechMode == .applySpeakAfterTakingSeat, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.unmuteLocalAudio()
        guard !engineManager.store.audioSetting.isMicOpened else { return }
        engineManager.openLocalMicrophone()
    }
    
    func muteLocalVideoAction(sender: UIButton) {
        if currentUser.hasVideoStream {
            engineManager.closeLocalCamera()
            return
        }
        //如果房主全体禁画，房间成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开摄像头
        if roomInfo.speechMode == .applySpeakAfterTakingSeat, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        engineManager.openLocalCamera()
    }
    
    func muteAudioAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let mute = userInfo.hasAudioStream
        if mute {
            engineManager.closeRemoteDeviceByAdmin(userId: userId, device: .microphone) {
                sender.isSelected = !sender.isSelected
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }
        } else {
            viewResponder?.makeToast(text: .invitedOpenAudioText)
            guard !hasOpenMicrophoneInvite else { return }
            engineManager.openRemoteDeviceByAdmin(userId: userId, device: .microphone, onAccepted: { [weak self] _, _ in
                guard let self = self else { return }
                sender.isSelected = !sender.isSelected
                self.hasOpenMicrophoneInvite = false
            }, onRejected: { [weak self] _, _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
                self.viewResponder?.makeToast(text: userInfo.userName + localizedReplace(.muteAudioRejectToastText, replace: userInfo.userName))
            }, onCancelled: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
                self.viewResponder?.makeToast(text: .openAudioInvitationTimeoutText)
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }
            hasOpenMicrophoneInvite = true
        }
    }
    
    func muteVideoAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let mute = userInfo.hasVideoStream
        if mute {
            engineManager.closeRemoteDeviceByAdmin(userId: userId, device: .camera) { [weak self] in
                guard let _ = self else { return }
                sender.isSelected = !sender.isSelected
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }
        } else {
            viewResponder?.makeToast(text: .invitedOpenVideoText)
            guard !hasOpenCameraInvite else { return }
            engineManager.openRemoteDeviceByAdmin(userId: userId, device: .camera, onAccepted: { [weak self] _, _ in
                guard let self = self else { return }
                sender.isSelected = !sender.isSelected
                self.hasOpenCameraInvite = false
            }, onRejected: { [weak self] _, _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
                self.viewResponder?.makeToast(text: userInfo.userName + localizedReplace(.muteVideoRejectToastText, replace: userInfo.userName))
            }, onCancelled: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
                self.viewResponder?.makeToast(text: .openVideoInvitationTimeoutText)
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }
            hasOpenCameraInvite = true
        }
    }
    
    func inviteSeatAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !engineManager.store.extendedInvitationList.contains(userId) {
            engineManager.takeUserOnSeatByAdmin(userId: userId, timeout: timeoutNumber) { _,_ in
            } onRejected: { [weak self] requestId, userId, message in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: self.userName + .refusedTakeSeatInvitationText)
            } onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: .takeSeatInvitationTimeoutText)
            } onError: { [weak self] _, _, _, message in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: message)
            }
        }
        viewResponder?.makeToast(text: .invitedTakeSeatText)
        hideUserListManagerView()
    }
    
    func changeHostAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.changeUserRole(userId: userId, role: .roomOwner) { [weak self] in
            guard let self = self else { return }
            self.viewResponder?.showTransferredRoomOwnerAlert()
            debugPrint("转交主持人,success")
        } onError: { code, message in
            debugPrint("转交主持人，code,message")
        }
        hideUserListManagerView()
    }
    
    func muteMessageAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        let isDisable = !userInfo.disableSendingMessage
        userInfo.disableSendingMessage = !userInfo.disableSendingMessage
        engineManager.disableSendingMessageByAdmin(userId: userId, isDisable: isDisable)
    }
    
    func kickRemoteUserOffSeat(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.kickUserOffSeatByAdmin(userId: userId)
        hideUserListManagerView()
    }
    
    func kickOutAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let kickOutTitle = localizedReplace(.kickOutText, replace: userName)
        viewResponder?.showKickOutAlert(title: kickOutTitle, sureAction: { [weak self] in
            guard let self = self else { return }
            self.engineManager.kickRemoteUserOutOfRoom(userId: self.userId)
            self.hideUserListManagerView()
        })
    }
    
    //根据用户的状态更新item数组
    func updateUserItem() {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        userName = userInfo.userName
        updateItem(buttonType: .muteAudioItemType, muted: !userInfo.hasAudioStream)
        updateItem(buttonType: .muteVideoItemType, muted: !userInfo.hasVideoStream)
        updateItem(buttonType: .muteMessageItemType, muted: userInfo.disableSendingMessage)
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
    
    private func hideUserListManagerView() {
        self.viewResponder?.setUserListManagerViewHidden(isHidden: true)
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserListManagerDisplayStatusChanged,
                                               param: ["isPresent":false])
    }
}

extension UserListManagerViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        if name == .onUserAudioStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            guard userId == self.userId else { return }
            updateItem(buttonType: .muteAudioItemType, muted: !hasAudio)
        }
        if name == .onUserVideoStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard userId == self.userId, streamType == .cameraStream else { return }
            updateItem(buttonType: .muteVideoItemType, muted: !hasVideo)
        }
        if name == .onSendMessageForUserDisableChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let muted = param?["muted"] as? Bool else { return }
            guard userId == self.userId else { return }
            updateItem(buttonType: .muteMessageItemType, muted: muted)
        }
    }
}

private extension String {
    static var muteAudioErrorToastText: String {
        localized("TUIRoom.mute.audio.error.toast")
    }
    static var muteAudioRejectToastText: String {
        localized("TUIRoom.mute.audio.reject.toast")
    }
    static var muteVideoErrorToastText: String {
        localized("TUIRoom.mute.video.error.toast")
    }
    static var muteVideoRejectToastText: String {
        localized("TUIRoom.mute.video.reject.toast")
    }
    static var muteText: String {
        localized("TUIRoom.mute")
    }
    static var unmuteText: String {
        localized("TUIRoom.unmute")
    }
    static var requestOpenVideoText: String {
        localized("TUIRoom.request.open.video")
    }
    static var openVideoText: String {
        localized("TUIRoom.open.video")
    }
    static var requestOpenAudioText: String {
        localized("TUIRoom.request.open.audio")
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
    static var muteSeatReasonText: String {
        localized("TUIRoom.mute.seat.reason")
    }
    static var muteAudioRoomReasonText: String {
        localized("TUIRoom.mute.audio.room.reason")
    }
    static var muteVideoRoomReasonText: String {
        localized("TUIRoom.mute.video.room.reason")
    }
    static var invitedTakeSeatText: String {
        localized("TUIRoom.invited.take.seat")
    }
    static var refusedTakeSeatInvitationText: String {
        localized("TUIRoom.refused.take.seat.invitation")
    }
    static var takeSeatInvitationTimeoutText: String {
        localized("TUIRoom.take.seat.invitation.timeout")
    }
    static var openVideoInvitationTimeoutText: String {
        localized("TUIRoom.open.video.invitation.timeout")
    }
    static var openAudioInvitationTimeoutText: String {
        localized("TUIRoom.open.audio.invitation.timeout")
    }
    static var invitedOpenAudioText: String {
        localized("TUIRoom.invited.open.audio")
    }
    static var invitedOpenVideoText: String {
        localized("TUIRoom.invited.open.video")
    }
    static var kickOutText: String {
        localized("TUIRoom.sure.kick.out")
    }
}
