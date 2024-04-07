//
//  RoomManager.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/3.
//  管理房间，包括房间的创建、进入、退出、销毁和转换房主的操作

import Foundation
import TUIRoomEngine
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
    
    //判断是否已经进入其他房间
    func isEnteredOtherRoom(roomId: String) -> Bool {
        return roomInfo.roomId != roomId && roomInfo.roomId != ""
    }
    
    func createRoom(roomInfo: TUIRoomInfo) {
        roomId = roomInfo.roomId
        roomObserver.registerObserver()
        engineManager.store.isShowRoomMainViewAutomatically = false
        TUIRoomKit.createInstance().createRoom(roomInfo: roomInfo) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.createdRoom()
            self.enterRoom(roomId: roomInfo.roomId)
        } onError: { code, message in
            RoomCommon.getCurrentWindowViewController()?.view.makeToast(message)
            debugPrint("createRoom:code:\(code),message:\(message)")
        }
    }
    
    func enterRoom(roomId: String) {
        roomObserver.registerObserver()
        engineManager.store.isImAccess = true
        engineManager.enterRoom(roomId: roomId, enableAudio: engineManager.store.isOpenMicrophone, enableVideo:
                                    engineManager.store.isOpenCamera, isSoundOnSpeaker: true) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.enteredRoom()
        } onError: { code, message in
            RoomCommon.getCurrentWindowViewController()?.view.makeToast(message)
            debugPrint("enterRoom:code:\(code),message:\(message)")
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
    
    //退出之前进入的房间
    func exitOrDestroyPreviousRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        if roomInfo.ownerId == userId {
            if let userModel = engineManager.store.attendeeList.first(where: { $0.userId != userId }) {
                //如果之前创建的房间还没有被销毁，且有其他用户在房间内，在发送快速会议之前要转移房主
                changeUserRole(userId: userModel.userId, role: .roomOwner) { [weak self] in
                    guard let self = self else { return }
                    self.exitRoom(onSuccess: onSuccess, onError: onError)
                } onError: { [weak self] code, message in
                    guard let self = self else { return }
                    self.destroyRoom(onSuccess: onSuccess, onError: onError)
                }
            } else {
                //之前创建过房间且没有销毁，房间没有其他人，在发送快速会议前要销毁房间
                destroyRoom(onSuccess: onSuccess, onError: onError)
            }
        } else {
            //之前加入过房间，在快速会议前要先退出房间
            exitRoom(onSuccess: onSuccess, onError: onError)
        }
    }
}
