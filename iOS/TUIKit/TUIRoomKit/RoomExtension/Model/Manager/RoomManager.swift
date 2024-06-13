//
//  RoomManager.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/7/3.
//  Manage rooms, including room creation, entry, exit, destruction and conversion operations of the host

import Foundation
import RTCRoomEngine
import TUICore

class RoomManager {
    static let shared = RoomManager()
    private var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    private var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    private lazy var userId: String = {
        return TUILogin.getUserID() ?? engineManager.store.currentUser.userId
    }()
    private let messageManager = RoomMessageManager.shared
    let roomObserver: RoomObserver = RoomObserver()
    var roomId: String?
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    func isEnteredOtherRoom(roomId: String) -> Bool {
        return roomInfo.roomId != roomId && roomInfo.roomId != ""
    }
    
    func createRoom(roomInfo: TUIRoomInfo) {
        roomId = roomInfo.roomId
        roomObserver.registerObserver()
        engineManager.createRoom(roomInfo: roomInfo) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.createdRoom()
            self.enterRoom(roomId: roomInfo.roomId, isShownConferenceViewController: false)
        } onError: { _, message in
            RoomRouter.makeToast(toast: message)
        }
    }
    
    func enterRoom(roomId: String, isShownConferenceViewController: Bool = true) {
        roomObserver.registerObserver()
        engineManager.store.isImAccess = true
        self.roomId = roomId
        engineManager.enterRoom(roomId: roomId, enableAudio: engineManager.store.isOpenMicrophone, enableVideo: engineManager.store.isOpenCamera, isSoundOnSpeaker: true) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.enteredRoom()
            guard isShownConferenceViewController else { return }
            let vc = ConferenceMainViewController()
            RoomRouter.shared.push(viewController: vc)
        } onError: { _, message in
            RoomRouter.makeToast(toast: message)
        }
    }
    
    func exitRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        engineManager.exitRoom { [weak self] in
            guard let self = self else { return }
            self.refreshSource()
            self.messageManager.isReadyToSendMessage = true
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.refreshSource()
            if code.rawValue == -2_102 {
                self.destroyRoom(onSuccess: onSuccess, onError: onError)
            } else {
                onError(code, message)
            }
        }
    }
    
    func destroyRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        engineManager.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.roomObserver.messageModel.roomState = .destroyed
            self.refreshSource()
            self.messageManager.isReadyToSendMessage = true
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.refreshSource()
            onError(code, message)
        }
    }
    
    private func refreshSource() {
        roomId = nil
        TUILogin.setCurrentBusinessScene(.None)
        roomObserver.userList = []
        roomObserver.unregisterObserver()
    }
    
    private func changeUserRole(userId: String, role: TUIRole, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        engineManager.changeUserRole(userId: userId, role: .roomOwner) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    func exitOrDestroyPreviousRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        if roomInfo.ownerId == userId {
            if let userModel = engineManager.store.attendeeList.first(where: { $0.userId != userId }) {
                changeUserRole(userId: userModel.userId, role: .roomOwner) { [weak self] in
                    guard let self = self else { return }
                    self.exitRoom(onSuccess: onSuccess, onError: onError)
                } onError: { [weak self] code, message in
                    guard let self = self else { return }
                    self.destroyRoom(onSuccess: onSuccess, onError: onError)
                }
            } else {
                destroyRoom(onSuccess: onSuccess, onError: onError)
            }
        } else {
            exitRoom(onSuccess: onSuccess, onError: onError)
        }
    }
}
