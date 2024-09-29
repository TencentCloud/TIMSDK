//
//  UserListViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine
import Factory

protocol UserListViewResponder: NSObject {
    func updateBottomControlView(isHidden: Bool)
    func reloadUserListView()
    func makeToast(text: String)
    func updateUserManagerViewDisplayStatus(isHidden: Bool)
    func updateMuteAllAudioButtonState(isSelect: Bool)
    func updateMuteAllVideoButtonState(isSelect: Bool)
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?)
    func updateListStateView()
    func updateMemberLabel(count: Int)
    func updateUserListTableView()
}

class UserListViewModel: NSObject {
    var userId: String = ""
    var userName: String = ""
    var attendeeList: [UserEntity] = []
    var invitationList: [TUIInvitation] = []
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var store: RoomStore {
        engineManager.store
    }
    var currentUser: UserEntity {
        store.currentUser
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    let timeoutNumber: Double = 60
    weak var viewResponder: UserListViewResponder?
    lazy var userListType: UserListType = isSeatEnabled ? .onStageUsers: .allUsers
    var onStageCount: Int {
        store.seatList.count
    }
    var offStageCount: Int {
        store.offSeatList.count
    }
    var allUserCount: Int {
        store.attendeeList.count
    }
    var isShownBottomControlView: Bool {
        return store.currentUser.userRole != .generalUser
    }
    lazy var isSeatEnabled: Bool = {
        return roomInfo.isSeatEnabled
    }()
    lazy var isShownNotificationView: Bool = {
        return false
    }()
    lazy var isSearching: Bool = {
        return false
    }()
    lazy var searchText: String = {
        return ""
    }()
    var invitationUserList: [TUIInvitation] {
        return conferenceStore.selectCurrent(ConferenceInvitationSelectors.getInvitationList)
    }
    
    @Injected(\.conferenceStore) var conferenceStore
    
    override init() {
        super.init()
        updateAttendeeList()
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        debugPrint("deinit \(self)")
    }
    
    func updateAttendeeList() {
        var userList: [UserEntity] = []
        switch userListType {
        case .allUsers:
            userList = store.attendeeList
        case .onStageUsers:
            userList = store.seatList
        case .offStageUsers:
            userList = store.offSeatList
        case .notInRoomUsers:
            userList = invitationList.map{ UserEntity(invitation: $0) }
        }
        if isSearching, searchText.count > 0 {
            let searchArray = userList.filter({ model -> Bool in
                return (model.userName.contains(searchText))
            })
            attendeeList = searchArray
        } else {
            attendeeList = userList
        }
    }
    
    func muteAllAudioAction(sender: UIButton, view: UserListView) {
        let isSelected = sender.isSelected
        viewResponder?.showAlert(title: sender.isSelected ? .allUnmuteTitle : .allMuteTitle,
                                 message: sender.isSelected ? .allUnmuteMessage : .allMuteMessage,
                                 sureTitle: sender.isSelected ? .confirmReleaseText : .allMuteActionText,
                                 declineTitle: .cancelText, sureBlock: { [weak self] in
            guard let self = self else { return }
            if self.roomInfo.isMicrophoneDisableForAllUser != !isSelected {
                self.engineManager.muteAllAudioAction(isMute: !isSelected) {
                } onError: { [weak self] _, message in
                    guard let self = self else { return }
                    self.viewResponder?.makeToast(text:message)
                }
            } else {
                let text: String = isSelected ? .allUnMuteAudioText : .allMuteAudioText
                self.viewResponder?.makeToast(text: text)
            }
        }, declineBlock: nil)
    }
    
    func muteAllVideoAction(sender: UIButton, view: UserListView) {
        let isSelected = sender.isSelected
        viewResponder?.showAlert(title: sender.isSelected ? .allUnmuteVideoTitle : .allMuteVideoTitle,
                                 message: sender.isSelected ? .allUnmuteVideoMessage : .allMuteVideoMessage,
                                 sureTitle: sender.isSelected ? .confirmReleaseText : .allMuteVideoActionText,
                                 declineTitle: .cancelText, sureBlock: { [weak self] in
            guard let self = self else { return }
            if self.roomInfo.isCameraDisableForAllUser != !isSelected {
                self.engineManager.muteAllVideoAction(isMute: !isSelected) {
                } onError: { [weak self] _, message in
                    guard let self = self else { return }
                    self.viewResponder?.makeToast(text:message)
                }
            } else {
                let text: String = isSelected ? .allUnMuteVideoText : .allMuteVideoText
                self.viewResponder?.makeToast(text: text)
            }
        }, declineBlock: nil)
    }
    
    func showUserManageViewAction(userId: String, userName: String) {
        self.userId = userId
        self.userName = userName
        guard checkShowManagerView() else { return }
        viewResponder?.updateUserManagerViewDisplayStatus(isHidden: false)
    }
    
    private func checkShowManagerView() -> Bool {
        guard let userInfo = engineManager.store.attendeeList.first(where: { $0.userId == userId }) else { return false }
        if currentUser.userRole == .roomOwner, userId != currentUser.userId {
            return true
        } else if currentUser.userRole == .administrator, userId != currentUser.userId, userInfo.userRole == .generalUser {
            return true
        } else {
            return false
        }
    }
    
    func inviteSeatAction(sender: UIButton) {
        guard let userInfo = attendeeList.first(where: { $0.userId == userId }) else { return }
        guard store.seatList.count < roomInfo.maxSeatCount else {
            RoomRouter.makeToastInCenter(toast: .theStageIsFullText, duration: 0.5)
            return
        }
        engineManager.takeUserOnSeatByAdmin(userId: userId, timeout: timeoutNumber) { _,_ in
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
    }
    
    func checkSelfInviteAbility(invitee: UserEntity) -> Bool {
        if currentUser.userRole == .roomOwner {
            return true
        } else if currentUser.userRole == .administrator, invitee.userRole == .generalUser {
            return true
        } else {
            return false
        }
    }
    
    func changeListState(type: UserListType) {
        userListType = type
        updateAttendeeList()
        viewResponder?.reloadUserListView()
    }
    
    func compareLists(oldList: [TUIInvitation], newList: [TUIInvitation]) -> (added: [TUIInvitation], removed: [TUIInvitation], changed: [TUIInvitation]) {
        var added = [TUIInvitation]()
        var removed = [TUIInvitation]()
        var changed = [TUIInvitation]()
        let oldDict = Dictionary(uniqueKeysWithValues: oldList.map { ($0.invitee.userId, $0) })
        let newDict = Dictionary(uniqueKeysWithValues: newList.map { ($0.invitee.userId, $0) })
        
        for newInvitation in newList {
            if oldDict[newInvitation.invitee.userId] == nil {
                added.append(newInvitation)
            }
        }
        for oldInvitation in oldList {
            if newDict[oldInvitation.invitee.userId] == nil {
                removed.append(oldInvitation)
            }
        }
        for newInvitation in newList {
            if let oldInvitation = oldDict[newInvitation.invitee.userId], oldInvitation != newInvitation {
                changed.append(newInvitation)
            }
        }
        return (added, removed, changed)
    }
}

extension UserListViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            viewResponder?.updateMemberLabel(count: allUserCount)
            updateAttendeeList()
            viewResponder?.reloadUserListView()
            viewResponder?.updateListStateView()
        case .TUIRoomKitService_CurrentUserRoleChanged:
            guard let userRole = info?["userRole"] as? TUIRole else { return }
            viewResponder?.updateBottomControlView(isHidden: userRole == .generalUser)
        case .TUIRoomKitService_RoomOwnerChanged:
            viewResponder?.reloadUserListView()
        default: break
        }
    }
}

extension UserListViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onAllUserCameraDisableChanged:
            guard let isDisable = param?["isDisable"] as? Bool else { return }
            viewResponder?.updateMuteAllVideoButtonState(isSelect: isDisable)
        case .onAllUserMicrophoneDisableChanged:
            guard let isDisable = param?["isDisable"] as? Bool else { return }
            viewResponder?.updateMuteAllAudioButtonState(isSelect: isDisable)
        default: break
        }
    }
}

extension UserListViewModel: RaiseHandApplicationNotificationViewListener {
    func onShown() {
        isShownNotificationView = true
        viewResponder?.updateUserListTableView()
    }
    
    func onHidden() {
        isShownNotificationView = false
        viewResponder?.updateUserListTableView()
    }
}

private extension String {
    static var invitedTakeSeatText: String {
        localized("The audience has been invited to the stage")
    }
    static var refusedTakeSeatInvitationText: String {
        localized("xx refused to go on stage")
    }
    static var takeSeatInvitationTimeoutText: String {
        localized("The invitation to xx to go on stage has timed out")
    }
    static var allMuteTitle: String {
        localized("All current and incoming members will be muted")
    }
    static var allMuteVideoTitle: String {
        localized("All current and incoming members will be restricted from video")
    }
    static var allMuteMessage: String {
        localized("Members will unable to turn on the microphone")
    }
    static var allMuteVideoMessage: String {
        localized("Members will unable to turn on video")
    }
    static var allUnmuteMessage: String {
        localized("Members will be able to turn on the microphone")
    }
    static var allUnmuteVideoMessage: String {
        localized("Members will be able to turn on video")
    }
    static var allUnmuteTitle: String {
        localized("All members will be unmuted")
    }
    static var allUnmuteVideoTitle: String {
        localized("All members will not be restricted from video")
    }
    static var cancelText: String {
        localized("Cancel")
    }
    static var allMuteActionText: String {
        localized("Mute All")
    }
    static var allMuteVideoActionText: String {
        localized("Stop all video")
    }
    static var confirmReleaseText: String {
        localized("Confirm release")
    }
    static var allMuteAudioText: String {
        localized("All audios disabled")
    }
    static var allUnMuteAudioText: String {
        localized("All audios enabled")
    }
    static var allMuteVideoText: String {
        localized("All videos disabled")
    }
    static var allUnMuteVideoText: String {
        localized("All videos enabled")
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
