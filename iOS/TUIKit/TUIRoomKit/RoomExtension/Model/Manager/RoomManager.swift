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
    var isEngineLogin: Bool = false
    private var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    private var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    private lazy var userId: String = {
        return TUILogin.getUserID() ?? engineManager.store.currentUser.userId
    }()
    private let messageManager = RoomMessageManager.shared
    let roomObserver: RoomObserver = RoomObserver()
    var roomId: String?
    private init() {
        roomId = getRoomId()
    }
    deinit {
        debugPrint("deinit \(self)")
    }
    
    func getRoomId() -> String? {
        guard let userId = TUILogin.getUserID() else { return nil }
        //从100到999依次创建房间
        var roomNumber = UserDefaults.standard.integer(forKey: "roomNumber")
        if roomNumber >= 100 && roomNumber < 999 {
            roomNumber = roomNumber + 1
        } else {
            roomNumber = 100
        }
        UserDefaults.standard.set(roomNumber, forKey: "roomNumber")
        let userString = String(roomNumber) + userId
        let roomId = String("\(userString)_room_kit".hash & roomHashNumber)
        return roomId
    }
    
    //判断是否已经进入其他房间
    func isEnteredOtherRoom(roomId: String) -> Bool {
        return roomInfo.roomId != roomId && roomInfo.roomId != ""
    }
    
    func createRoom(roomInfo: RoomInfo) {
        roomId = roomInfo.roomId
        roomObserver.registerObserver()
        engineManager.store.isChatAccessRoom = true
        engineManager.store.isShowRoomMainViewAutomatically = false
        TUIRoomKit.createInstance().createRoom(roomInfo: roomInfo) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.createdRoom()
            self.enterRoom(roomInfo: roomInfo)
        } onError: { code, message in
            debugPrint("createRoom:code:\(code),message:\(message)")
        }
    }
    
    func enterRoom(roomInfo: RoomInfo) {
        roomId = roomInfo.roomId
        roomObserver.registerObserver()
        engineManager.store.isChatAccessRoom = true
        TUIRoomKit.createInstance().enterRoom(roomInfo: roomInfo) { [weak self] in
            guard let self = self else { return }
            self.roomObserver.enteredRoom()
        } onError: { code, message in
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
            if self.roomObserver.messageModel.owner == self.userId {
                self.messageManager.resendRoomMessage(message: self.roomObserver.messageModel, dic:
                                                        ["roomState":RoomMessageModel.RoomState.destroyed.rawValue])
            }
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
        engineManager.roomEngine.changeUserRole(userId: userId, role: .roomOwner) {
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
    
    func loginEngine(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        let sdkAppId = Int(TUILogin.getSdkAppID())
        let userSig = TUILogin.getUserSig() ?? ""
        V2TIMManager.sharedInstance().initSDK(Int32(sdkAppId), config: V2TIMSDKConfig())
        TUIRoomEngine.login(sdkAppId: sdkAppId, userId: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            self.engineManager.store.currentUser.userId = self.userId
            self.isEngineLogin = true
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
}
