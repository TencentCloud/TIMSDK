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
    func updateUIWhenRoomOwnerChanged(roomOwner:String)
    func reloadUserListView()
    func makeToast(text: String)
    func searchControllerChangeActive(isActive: Bool)
}

class UserListViewModel: NSObject {
    var userId: String = ""
    var attendeeList: [UserModel] = []
    
    let timeoutNumber: Double = 30
    weak var viewResponder: UserListViewResponder? = nil
    
    override init() {
        super.init()
        self.attendeeList = EngineManager.shared.store.attendeeList
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        debugPrint("deinit \(self)")
    }
    
    func muteAllAudioAction(sender: UIButton, view: UserListView) {
        sender.isSelected = !sender.isSelected
        let roomInfo = EngineManager.shared.store.roomInfo
        roomInfo.isMicrophoneDisableForAllUser = sender.isSelected
        EngineManager.shared.roomEngine.disableDeviceForAllUserByAdmin(device: .microphone, isDisable:
                                                                        roomInfo.isMicrophoneDisableForAllUser) { [weak self] in
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
        let roomInfo = EngineManager.shared.store.roomInfo
        roomInfo.isCameraDisableForAllUser = sender.isSelected
        EngineManager.shared.roomEngine.disableDeviceForAllUserByAdmin(device: .camera, isDisable:
                                                                        roomInfo.isCameraDisableForAllUser) { [weak self] in
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
        if EngineManager.shared.store.currentUser.userRole == .roomOwner || EngineManager.shared.store.currentUser.userId == userId {
            view.userListManagerView.isHidden = false
            view.userListManagerView.viewModel.userId = userId
            view.userListManagerView.viewModel.updateUserItem()
        }
    }
    
    func inviteSeatAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        EngineManager.shared.roomEngine.takeUserOnSeatByAdmin(-1, userId: userId, timeout: timeoutNumber) { _, _ in
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
    
    func backAction() {
        RoomRouter.shared.dismissPopupViewController(viewType: .userListViewType)
    }
}

extension UserListViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        if name == .onUserRoleChanged {
            guard let userRole = param?["userRole"] as? TUIRole, userRole == .roomOwner else { return }
            guard let userId = param?["userId"] as? String else { return }
            viewResponder?.updateUIWhenRoomOwnerChanged(roomOwner: userId)
        }
    }
}

extension UserListViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            attendeeList = EngineManager.shared.store.attendeeList
            viewResponder?.reloadUserListView()
        default: break
        }
    }
}

extension UserListViewModel: PopUpViewResponder {
    func updateViewOrientation(isLandscape: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: false)
        attendeeList = EngineManager.shared.store.attendeeList
        viewResponder?.reloadUserListView()
    }
    
    func searchControllerChangeActive(isActive: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: isActive)
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
