//
//  UserListManagerViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/2/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

protocol UserListManagerViewEventResponder: AnyObject {
    func makeToast(text: String)
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?)
    func setUserListManagerViewHidden(isHidden: Bool)
    func dismissView()
    func updateUI(item: ButtonItemData)
    func updateStackView(items:[ButtonItemData])
    func addStackView(item: ButtonItemData, index: Int?)
    func removeStackView(itemType: ButtonItemData.ButtonType)
}

class UserListManagerViewModel: NSObject {
    var selectUserId: String = ""
    let timeoutNumber: Double = 60
    var userListManagerItems: [ButtonItemData] = []
    weak var viewResponder: UserListManagerViewEventResponder?
    var engineManager: EngineManager {
        EngineManager.shared
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
    var selectUserInfo: UserEntity? {
        attendeeList.first(where: { $0.userId == selectUserId } )
    }
    
    init(selectUserId: String) {
        self.selectUserId = selectUserId
        super.init()
        createManagerItems()
        subscribeEngine()
    }
    
    deinit {
        unsubscribeEngine()
        debugPrint("self:\(self)")
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onSeatListChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onSeatListChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
    }
    
    private func createManagerItems() {
        if checkMediaShownState() {
            userListManagerItems.append(muteAudioItem)
            userListManagerItems.append(muteVideoItem)
        }
        if checkInviteSeatItemShownState() {
            userListManagerItems.append(inviteSeatItem)
        }
        if checkChangeHostItemShownState() {
            userListManagerItems.append(changeHostItem)
        }
        if checkSetAdministratorItemShownState() {
            userListManagerItems.append(setAdministratorItem)
        }
        if checkMuteMessageItemShownState() {
            userListManagerItems.append(muteMessageItem)
        }
        if checkKickOutItemShownState() {
            userListManagerItems.append(kickOutItem)
        }
    }
    
    private lazy var muteAudioItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .muteText
        item.normalIcon = "room_unMute_audio"
        item.selectedTitle = .requestOpenAudioText
        item.selectedIcon = "room_mute_audio"
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .muteAudioItemType
        item.isSelect = !(selectUserInfo?.hasAudioStream ?? true)
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteAudioAction(sender: button)
        }
        return item
    }()
    
    private lazy var muteVideoItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .closeVideoText
        item.normalIcon = "room_unMute_video"
        item.selectedTitle = .requestOpenVideoText
        item.selectedIcon = "room_mute_video"
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .muteVideoItemType
        item.isSelect = !(selectUserInfo?.hasVideoStream ?? true)
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteVideoAction(sender: button)
        }
        return item
    }()
    
    private lazy var inviteSeatItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .inviteSeatText
        item.normalIcon = "room_invite_seat"
        item.selectedTitle = .stepDownSeatText
        item.selectedIcon = "room_step_down_seat"
        item.resourceBundle = tuiRoomKitBundle()
        item.isSelect = selectUserInfo?.isOnSeat ?? false
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.inviteSeatAction(sender: button)
        }
        return item
    }()
    
    private lazy var changeHostItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .changeHostText
        item.normalIcon = "room_change_host"
        item.resourceBundle = tuiRoomKitBundle()
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.changeHostAction(sender: button)
        }
        return item
    }()
    
    private lazy var muteMessageItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .muteMessageText
        item.normalIcon = "room_mute_message"
        item.selectedTitle = .unMuteMessageText
        item.selectedIcon = "room_unMute_message"
        item.resourceBundle = tuiRoomKitBundle()
        item.isSelect = selectUserInfo?.disableSendingMessage ?? false
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteMessageAction(sender: button)
        }
        return item
    }()
    
    private lazy var kickOutItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .kickOutRoomText
        item.normalIcon = "room_kickOut_room"
        item.resourceBundle = tuiRoomKitBundle()
        item.hasLineView = true
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.kickOutAction(sender: button)
        }
        return item
    }()
    
    private lazy var setAdministratorItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .setAsAdministratorText
        item.selectedTitle = .undoAdministratorText
        item.normalIcon = "room_set_administrator"
        item.selectedIcon = "room_undo_administrator"
        item.resourceBundle = tuiRoomKitBundle()
        item.isSelect = selectUserInfo?.userRole == .administrator
        item.hasLineView = true
        item.action = {  [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.setAdministratorAction(sender: button)
        }
        return item
    }()
    
    func backBlockAction(sender: UIView) {
        sender.isHidden = true
    }
    
    private func checkMediaShownState() -> Bool {
        guard let selectUserInfo = selectUserInfo else { return false }
        if !roomInfo.isSeatEnabled {
            return true
        } else if selectUserInfo.isOnSeat {
            return true
        }
        return false
    }
    
    private func checkInviteSeatItemShownState() -> Bool {
        return roomInfo.isSeatEnabled
    }
    
    private func checkChangeHostItemShownState() -> Bool {
        return currentUser.userRole == .roomOwner
    }
    
    private func checkMuteMessageItemShownState() -> Bool {
        return true
    }
    
    private func checkKickOutItemShownState() -> Bool {
        return currentUser.userRole == .roomOwner
    }
    
    private func checkSetAdministratorItemShownState() -> Bool {
        return currentUser.userRole == .roomOwner
    }
}

extension UserListManagerViewModel {
    private func addViewItem(buttonItem: ButtonItemData, index: Int) {
        guard !isContainedViewItem(buttonType: buttonItem.buttonType) else { return }
        if userListManagerItems.count > index + 1 {
            userListManagerItems.insert(buttonItem, at: index)
            viewResponder?.addStackView(item: buttonItem, index: index)
        } else {
            userListManagerItems.append(buttonItem)
            viewResponder?.addStackView(item: buttonItem, index: nil)
        }
    }
    
    private func removeViewItem(buttonType: ButtonItemData.ButtonType) {
        userListManagerItems.removeAll(where: { $0.buttonType == buttonType })
        viewResponder?.removeStackView(itemType: buttonType)
    }
    
    private func isContainedViewItem(buttonType: ButtonItemData.ButtonType) -> Bool {
        return userListManagerItems.contains(where: { $0.buttonType == buttonType })
    }
    
    private func muteAudioAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == selectUserId }) else { return }
        let mute = userInfo.hasAudioStream
        if mute {
            engineManager.closeRemoteDeviceByAdmin(userId: selectUserId, device: .microphone) {
                sender.isSelected = !sender.isSelected
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteAudioErrorToastText, replace: userInfo.userName))
            }
        } else {
            viewResponder?.makeToast(text: .invitedOpenAudioText)
            guard !hasOpenMicrophoneInvite else {
                viewResponder?.dismissView()
                return
            }
            engineManager.openRemoteDeviceByAdmin(userId: selectUserId, device: .microphone, onAccepted: { [weak self] _, _ in
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
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
                self.viewResponder?.makeToast(text: .openAudioInvitationTimeoutText)
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.hasOpenMicrophoneInvite = false
            }
            hasOpenMicrophoneInvite = true
        }
        viewResponder?.dismissView()
    }
    
    private func muteVideoAction(sender: UIButton) {
        guard let userInfo = selectUserInfo else { return }
        let mute = userInfo.hasVideoStream
        if mute {
            engineManager.closeRemoteDeviceByAdmin(userId: selectUserId, device: .camera) { [weak self] in
                guard let _ = self else { return }
                sender.isSelected = !sender.isSelected
            } onError: { [weak self] _, _ in
                guard let self = self else { return }
                self.viewResponder?.makeToast(text: localizedReplace(.muteVideoErrorToastText, replace: userInfo.userName))
            }
        } else {
            viewResponder?.makeToast(text: .invitedOpenVideoText)
            guard !hasOpenCameraInvite else {
                viewResponder?.dismissView()
                return
            }
            engineManager.openRemoteDeviceByAdmin(userId: selectUserId, device: .camera, onAccepted: { [weak self] _, _ in
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
            }, onTimeout: { [weak self] _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
                self.viewResponder?.makeToast(text: .openVideoInvitationTimeoutText)
            }) { [weak self] _, _, _, _ in
                guard let self = self else { return }
                self.hasOpenCameraInvite = false
            }
            hasOpenCameraInvite = true
        }
        viewResponder?.dismissView()
    }
    
    func inviteSeatAction(sender: UIButton) {
        guard let userInfo = selectUserInfo else { return }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            guard engineManager.store.seatList.count < roomInfo.maxSeatCount else {
                RoomRouter.makeToastInCenter(toast: .theStageIsFullText, duration: 0.5)
                viewResponder?.dismissView()
                return
            }
            engineManager.takeUserOnSeatByAdmin(userId: selectUserId, timeout: timeoutNumber) { _,_ in
                let text: String = localizedReplace(.onStageText, replace: userInfo.userName)
                RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
            } onRejected: { requestId, userId, message in
                let text: String = localizedReplace(.refusedTakeSeatInvitationText, replace: userInfo.userName)
                RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
            } onCancelled: { _, _ in
            } onTimeout: { _, _ in
                let text: String = localizedReplace(.takeSeatInvitationTimeoutText, replace: userInfo.userName)
                RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
            } onError: { _, _, code, message in
                let text: String = code == .requestIdRepeat ? .receivedSameRequestText : message
                RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
            }
            viewResponder?.makeToast(text: .invitedTakeSeatText)
        } else {
            engineManager.kickUserOffSeatByAdmin(userId: selectUserId)
        }
        viewResponder?.dismissView()
    }
    
    private func changeHostAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == selectUserId }) else { return }
        let title = localizedReplace(.transferHostTitle, replace: userInfo.userName)
        viewResponder?.showAlert(title: title, message: .transferHostMessage, sureTitle: .transferHostsureText, declineTitle: .cancelText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.engineManager.changeUserRole(userId: self.selectUserId, role: .roomOwner) { [weak self] in
                guard let self = self else { return }
                let text = localizedReplace(.haveTransferredMasterText, replace: userInfo.userName)
                self.viewResponder?.makeToast(text: text)
                self.viewResponder?.dismissView()
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                self.viewResponder?.dismissView()
            }
        }, declineBlock: nil)
    }
    
    private func muteMessageAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == selectUserId }) else { return }
        engineManager.disableSendingMessageByAdmin(userId: selectUserId, isDisable: !userInfo.disableSendingMessage)
        viewResponder?.dismissView()
    }
    
    func kickOutAction(sender: UIButton) {
        let kickOutTitle = localizedReplace(.kickOutText, replace: selectUserInfo?.userName ?? "")
        viewResponder?.showAlert(title: kickOutTitle, message: nil, sureTitle: .alertOkText, declineTitle: .cancelText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.engineManager.kickRemoteUserOutOfRoom(userId: self.selectUserId)
            self.viewResponder?.dismissView()
        }, declineBlock: nil)
    }
    
    private func setAdministratorAction(sender: UIButton) {
        guard let userInfo = selectUserInfo else { return }
        let role: TUIRole = userInfo.userRole == .administrator ? .generalUser : .administrator
        engineManager.changeUserRole(userId: selectUserId, role: role) {  [weak self] in
            guard let self = self else { return }
            let setAdministratorText = localizedReplace(.setUpAdministratorText, replace: userInfo.userName)
            let removeAdministratorText = localizedReplace(.removedAdministratorText, replace: userInfo.userName)
            let text: String = role == .administrator ? setAdministratorText : removeAdministratorText
            self.viewResponder?.makeToast(text: text)
            self.viewResponder?.dismissView()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.viewResponder?.dismissView()
            debugPrint("changeUserRole,code:\(code),message:\(message)")
        }
    }
}

extension UserListManagerViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onUserAudioStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            guard userId == selectUserId else { return }
            muteAudioItem.isSelect = !hasAudio
            viewResponder?.updateUI(item: muteAudioItem)
        case .onUserVideoStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard userId == selectUserId, streamType == .cameraStream else { return }
            muteVideoItem.isSelect = !hasVideo
            viewResponder?.updateUI(item: muteVideoItem)
        case .onSendMessageForUserDisableChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let muted = param?["muted"] as? Bool else { return }
            guard userId == selectUserId else { return }
            muteMessageItem.isSelect = muted
            viewResponder?.updateUI(item: muteMessageItem)
        case .onSeatListChanged:
            if let seated = param?["seated"] as? [TUISeatInfo], seated.first(where: { $0.userId == selectUserId }) != nil {
                inviteSeatItem.isSelect = true
                viewResponder?.updateUI(item: inviteSeatItem)
                addViewItem(buttonItem: muteAudioItem, index: 0)
                addViewItem(buttonItem: muteVideoItem, index: 1)
            }
            if let left = param?["left"] as? [TUISeatInfo], left.first(where: { $0.userId == selectUserId }) != nil {
                inviteSeatItem.isSelect = false
                viewResponder?.updateUI(item: inviteSeatItem)
                removeViewItem(buttonType: .muteAudioItemType)
                removeViewItem(buttonType: .muteVideoItemType)
            }
        case .onUserRoleChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let userRole = param?["userRole"] as? TUIRole else { return }
            guard userId == currentUser.userId || userId == selectUserId else { return }
            guard currentUser.userId != selectUserId else { return }
            guard let selectUserInfo = selectUserInfo else { return }
            userListManagerItems.removeAll()
            if currentUser.userRole == .roomOwner {
                createManagerItems()
                viewResponder?.updateStackView(items: userListManagerItems)
            } else if currentUser.userRole == .administrator, selectUserInfo.userRole == .generalUser {
                createManagerItems()
                viewResponder?.updateStackView(items: userListManagerItems)
            } else {
                viewResponder?.dismissView()
            }
        default: break
        }
    }
}

private extension String {
    static var muteAudioErrorToastText: String {
        localized("Failed to mute.")
    }
    static var muteAudioRejectToastText: String {
        localized(" rejected to the microphone access request.")
    }
    static var muteVideoErrorToastText: String {
        localized("Failed to disable video.")
    }
    static var muteVideoRejectToastText: String {
        localized(" rejected to the camera access request.")
    }
    static var muteText: String {
        localized("Mute")
    }
    static var requestOpenVideoText: String {
        localized("Ask to start video")
    }
    static var requestOpenAudioText: String {
        localized("Ask to unmute")
    }
    static var closeVideoText: String {
        localized("Stop video")
    }
    static var changeHostText: String {
        localized("Make host")
    }
    static var muteMessageText: String {
        localized("Disable chat")
    }
    static var unMuteMessageText: String {
        localized("Enable chat")
    }
    static var kickOutRoomText: String {
        localized("Remove")
    }
    static var stepDownSeatText: String {
        localized("Leave the stage")
    }
    static var inviteSeatText: String {
        localized("Invite to stage")
    }
    static var invitedTakeSeatText: String {
        localized("The audience has been invited to the stage")
    }
    static var refusedTakeSeatInvitationText: String {
        localized("xx refused to go on stage")
    }
    static var takeSeatInvitationTimeoutText: String {
        localized("The invitation to xx to go on stage has timed out")
    }
    static var openVideoInvitationTimeoutText: String {
        localized("The invitation to start the video has timed out")
    }
    static var openAudioInvitationTimeoutText: String {
        localized("The invitation to start the audio has timed out")
    }
    static var invitedOpenAudioText: String {
        localized("The audience has been invited to open the audio")
    }
    static var invitedOpenVideoText: String {
        localized("The audience has been invited to open the video")
    }
    static var kickOutText: String {
        localized("Do you want to move xx out of the conference?")
    }
    static var setAsAdministratorText: String {
        localized("Set as administrator")
    }
    static var undoAdministratorText: String {
        localized("Undo administrator")
    }
    static var haveTransferredMasterText: String {
        localized("The host has been transferred to xx")
    }
    static var setUpAdministratorText: String {
        localized("xx has been set as conference admin")
    }
    static var removedAdministratorText: String {
        localized("The conference admin status of xx has been withdrawn")
    }
    static var alertOkText: String {
        localized("OK")
    }
    static var cancelText: String {
        localized("Cancel")
    }
    static var transferHostTitle: String {
        localized("Transfer the host to xx")
    }
    static var transferHostMessage: String {
        localized("After transfer the host, you will become a general user")
    }
    static var transferHostsureText: String {
        localized("Confirm transfer")
    }
    static var receivedSameRequestText: String {
        localized("This member has already received the same request, please try again later")
    }
    static var onStageText: String {
        localized("xx is on stage")
    }
    static var theStageIsFullText: String {
        localized("The stage is full")
    }
}
