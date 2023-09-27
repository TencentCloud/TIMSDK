//
//  UserListViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

protocol UserListViewResponder: NSObject {
    func updateUIWhenRoomOwnerChanged(isOwner: Bool)
    func reloadUserListView()
    func makeToast(text: String)
    func updateBlurViewDisplayStatus(isHidden: Bool)
}

class UserListViewModel: NSObject {
    var userId: String = ""
    var attendeeList: [UserEntity] = []
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    let timeoutNumber: Double = 0
    weak var viewResponder: UserListViewResponder? = nil
    
    override init() {
        super.init()
        self.attendeeList = engineManager.store.attendeeList
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_UserListManagerDisplayStatusChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_UserListManagerDisplayStatusChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RoomOwnerChanged, responder: self)
        debugPrint("deinit \(self)")
    }
    
    func muteAllAudioAction(sender: UIButton, view: UserListView) {
        sender.isSelected = !sender.isSelected
        engineManager.muteAllAudioAction(isMute: sender.isSelected) { [weak self] in
            guard let self = self else { return }
            if sender.isSelected {
                self.viewResponder?.makeToast(text:.allMuteAudioText)
            } else {
                self.viewResponder?.makeToast(text:.allUnMuteAudioText)
            }
        } onError: { [weak self] _, message in
            guard let self = self else { return }
            self.viewResponder?.makeToast(text:message)
        }
    }
    
    func muteAllVideoAction(sender: UIButton, view: UserListView) {
        sender.isSelected = !sender.isSelected
        engineManager.muteAllVideoAction(isMute: sender.isSelected) { [weak self] in
            guard let self = self else { return }
            if sender.isSelected {
                self.viewResponder?.makeToast(text:.allMuteVideoText)
            } else {
                self.viewResponder?.makeToast(text:.allUnMuteVideoText)
            }
        } onError: { [weak self] _, message in
            guard let self = self else { return }
            self.viewResponder?.makeToast(text:message)
        }
    }
    
    func showUserManageViewAction(userId: String, view: UserListView) {
        self.userId = userId
        if currentUser.userId == roomInfo.ownerId || currentUser.userId == userId {
            view.userListManagerView.isHidden = false
            view.userListManagerView.viewModel.userId = userId
            view.userListManagerView.viewModel.updateUserItem()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserListManagerDisplayStatusChanged,
                                                   param: ["isPresent":true])
        }
    }
    
    func hideUserManageViewAction(view: UserListView) {
        view.userListManagerView.isHidden = true
    }
    
    func inviteSeatAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.takeUserOnSeatByAdmin(userId: userId, timeout: timeoutNumber)
    }
    
    func dropDownAction(sender: UIView) {
        RoomRouter.shared.dismissPopupViewController(viewType: .userListViewType, animated: true)
    }
}

extension UserListViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            attendeeList = engineManager.store.attendeeList
            viewResponder?.reloadUserListView()
        case .TUIRoomKitService_CurrentUserRoleChanged:
            guard let userRole = info?["userRole"] as? TUIRole else { return }
            viewResponder?.updateUIWhenRoomOwnerChanged(isOwner: userRole == .roomOwner)
        case .TUIRoomKitService_UserListManagerDisplayStatusChanged:
            guard let isPresent = info?["isPresent"] as? Bool else {return}
            viewResponder?.updateBlurViewDisplayStatus(isHidden: !isPresent)
        case .TUIRoomKitService_RoomOwnerChanged:
            viewResponder?.reloadUserListView()
        default: break
        }
    }
}

private extension String {
    static var allMuteAudioText: String {
        localized("TUIRoom.all.mute")
    }
    static var allMuteVideoText: String {
        localized("TUIRoom.all.mute.video")
    }
    static var allUnMuteAudioText: String {
        localized("TUIRoom.all.unmute")
    }
    static var allUnMuteVideoText: String {
        localized("TUIRoom.all.unmute.video")
    }
}
