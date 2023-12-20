//
//  ExitRoomViewModel.swift
//  TUIRoomKit
//
//  Created by krabyu on 2023/8/23.
//

import Foundation
import TUIRoomEngine

protocol ExitRoomViewModelResponder: AnyObject {
    func makeToast(message: String)
}

class ExitRoomViewModel {
    var engineManager: EngineManager
    var currentUser: UserEntity
    var isRoomOwner: Bool
    var isOnlyOneUserInRoom: Bool
    weak var viewResponder: ExitRoomViewModelResponder?
    
    init() {
        engineManager = EngineManager.createInstance()
        currentUser =  engineManager.store.currentUser
        isRoomOwner = currentUser.userId == engineManager.store.roomInfo.ownerId
        isOnlyOneUserInRoom = engineManager.store.attendeeList.count == 1
    }
    
    func isShownLeaveRoomButton() -> Bool {
        if currentUser.userId == engineManager.store.roomInfo.ownerId {
            return engineManager.store.attendeeList.count > 1
        } else {
            return true
        }
    }
    
    func isShownExitRoomButton() -> Bool {
        return currentUser.userId == engineManager.store.roomInfo.ownerId
    }
    
    func leaveRoomAction() {
        if isRoomOwner && !isOnlyOneUserInRoom {
            RoomRouter.shared.presentPopUpViewController(viewType: .transferMasterViewType, height: 720.scale375Height())
        } else {
            exitRoom()
        }
    }
    
    func exitRoom() {
        if isRoomOwner {
            engineManager.destroyRoom {
                RoomRouter.shared.dismissAllRoomPopupViewController()
                RoomRouter.shared.popToRoomEntranceViewController()
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                self.viewResponder?.makeToast(message: message)
            }
        } else {
            engineManager.exitRoom {
                RoomRouter.shared.dismissAllRoomPopupViewController()
                RoomRouter.shared.popToRoomEntranceViewController()
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                self.viewResponder?.makeToast(message: message)
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
