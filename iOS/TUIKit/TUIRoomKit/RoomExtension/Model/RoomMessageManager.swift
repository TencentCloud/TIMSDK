//
//  RoomMessageManager.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
import TUICore

protocol RoomMessageManagerListener: NSObject {
    func roomHasDestroyed(roomId: String)
}

class RoomMessageManager: NSObject {
    static let shared = RoomMessageManager()
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var roomEngine: TUIRoomEngine {
        engineManager.roomEngine
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    lazy var userId: String = {
        return TUILogin.getUserID() ?? engineManager.store.currentLoginUser.userId
    }()
    weak var listener: RoomMessageManagerListener?
    var roomId: String
    weak var navigateController: UINavigationController?
    var isEngineLogin: Bool = false //Engine是否登录
    var isReadyToSendMessage: Bool = true //是否可以发送新消息
    var groupId: String = ""
    private override init() {
        roomId = ""
        super.init()
    }
    
    func addListener(listener: RoomMessageManagerListener) {
        self.listener = listener
    }
    
    func removeListener() {
        self.listener = nil
    }
    
    func hasEnterRoom() -> Bool {
        return roomInfo.roomId != ""
    }
    
    func sendRoomMessageToGroup() {
        //首先判断现在是否已经进行TUICallKit的视频通话或者音频通话
        let businessScene = TUILogin.getCurrentBusinessScene()
        guard businessScene == .InMeetingRoom || businessScene == .None else {
            return
        }
        guard isReadyToSendMessage else {
            changeReadyToSendMessage()
            return
        }
        //判断是否已经登录Engine，如果没有登录，需要先进行登录
        if !isEngineLogin {
            TUIRoomKit.sharedInstance.addListener(listener: self)
            TUIRoomKit.sharedInstance.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID(), userSig: TUILogin.getUserSig())
            return
        }
        //判断现在是否在其他会议房间中
        if hasEnterRoom() {
            exitOrDestroyPreviousRoom() { [weak self] in
                guard let self = self else { return }
                self.sendMessage()
            } onError: { code, message in
                debugPrint("exitRoom,code:\(code),message:\(message)")
            }
        } else {
            sendMessage()
        }
    }
    
    //退出或者销毁之前进入的TUIRoomKit房间
    func exitOrDestroyPreviousRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        if roomInfo.ownerId == userId {
            if let userModel = engineManager.store.attendeeList.first(where: { $0.userId != userId }) {
                //如果之前创建的房间还没有被销毁，且有其他用户在房间内，在发送快速会议之前要转移房主
                changeRoleToSendMessage(userId: userModel.userId, onSuccess: onSuccess, onError: onError)
            } else {
                //之前创建过房间且没有销毁，房间没有其他人，在发送快速会议前要销毁房间
                destroyRoom(onSuccess: onSuccess, onError: onError)
            }
        } else {
            //之前加入过房间，在快速会议前要先退出房间
            exitRoom(onSuccess: onSuccess, onError: onError)
        }
    }
    
    private func changeReadyToSendMessage() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            guard let self = self else { return }
            self.isReadyToSendMessage = true
        }
    }
    
    private func destroyRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.closeLocalCamera()
        roomEngine.closeLocalMicrophone()
        roomEngine.stopPushLocalAudio()
        roomEngine.stopPushLocalVideo()
        roomEngine.stopScreenCapture()
        roomEngine.getTRTCCloud().setLocalVideoProcessDelegete(nil, pixelFormat: ._Texture_2D, bufferType: .texture)
        roomEngine.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.listener?.roomHasDestroyed(roomId: self.roomId)
            self.engineManager.refreshRoomEngine()
            self.engineManager.store.refreshStore()
            TUIRoomKit.sharedInstance.removeListener()
            self.removeListener()
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.listener?.roomHasDestroyed(roomId: self.roomId)
            self.engineManager.refreshRoomEngine()
            self.engineManager.store.refreshStore()
            TUIRoomKit.sharedInstance.removeListener()
            self.removeListener()
            onError(code, message)
        }
    }
    
    private func changeRoleToSendMessage(userId: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.changeUserRole(userId: userId, role: .roomOwner) { [weak self] in
            guard let self = self else { return }
            self.exitRoom(onSuccess: onSuccess, onError: onError)
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.destroyRoom(onSuccess: onSuccess, onError: onError)
        }
    }
    
    private func exitRoom(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.closeLocalCamera()
        roomEngine.closeLocalMicrophone()
        roomEngine.stopPushLocalAudio()
        roomEngine.stopPushLocalVideo()
        roomEngine.stopScreenCapture()
        roomEngine.getTRTCCloud().setLocalVideoProcessDelegete(nil, pixelFormat: ._Texture_2D, bufferType: .texture)
        roomEngine.exitRoom(syncWaiting: true) { [weak self] in
            guard let self = self else { return }
            self.engineManager.refreshRoomEngine()
            self.engineManager.store.refreshStore()
            TUIRoomKit.sharedInstance.removeListener()
            self.removeListener()
            onSuccess()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.engineManager.refreshRoomEngine()
            self.engineManager.store.refreshStore()
            TUIRoomKit.sharedInstance.removeListener()
            self.removeListener()
            onError(code, message)
        }
    }
    
    private func sendMessage() {
        isReadyToSendMessage = false
        guard let userId = TUILogin.getUserID() else { return }
        //从100到999依次创建房间
        var roomNumber = UserDefaults.standard.integer(forKey: "roomNumber")
        if roomNumber >= 100 && roomNumber < 999 {
            roomNumber = roomNumber + 1
        } else {
            roomNumber = 100
        }
        UserDefaults.standard.set(roomNumber, forKey: "roomNumber")
        let userString = String(roomNumber) + userId
        roomId = String("\(userString)_room_kit".hash & 0x3B9AC9FF)
        let dict = ["version":1,
                    "businessID": BussinessID_GroupRoomMessage,
                    "groupId":groupId,
                    "roomId":roomId,
                    "owner": TUILogin.getUserID() ?? "",
                    "ownerName":TUILogin.getNickName() ?? "",
                    "roomState": RoomMessageModel.RoomState.creating.rawValue,
                    "memberCount":0,
                    "messageId": "",
                    "userList":[],
        ] as [String : Any]
        guard let jsonString = dicValueString(dict) else { return }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        let message = V2TIMManager.sharedInstance().createCustomMessage(jsonData)
        message?.supportMessageExtension = true
        let param = [TUICore_TUIChatService_SendMessageMethod_MsgKey: message]
        TUICore.callService(TUICore_TUIChatService, method: TUICore_TUIChatService_SendMessageMethod, param: param as [AnyHashable : Any])
    }
    
    //修改message
    func resendRoomMessage(message: RoomMessageModel,dic:[String: Any]) {
        if message.messageId == "" {
            self.modifyMessage(message: message, dic: dic)
            return
        }
        V2TIMManager.sharedInstance().findMessages([message.messageId]) { [weak self] messageArray in
            guard let self = self else { return }
            guard let array = messageArray else { return }
            for previousMessage in array where previousMessage.msgID == message.messageId{
                self.modifyMessage(message: message, dic: dic)
            }
        } fail: { [weak self] code, messageString in
            guard let self = self else { return }
            self.modifyMessage(message: message, dic: dic)
        }
    }
    
    private func modifyMessage(message: RoomMessageModel, dic:[String: Any]) {
        guard var dict = TUITool.jsonData2Dictionary(message.getMessage().customElem.data) as? [String: Any] else { return }
        for (key, value) in dic {
            dict[key] = value
        }
        guard let jsonString = dicValueString(dict) else { return }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        message.getMessage().customElem.data = jsonData
        V2TIMManager.sharedInstance().modifyMessage(message.getMessage()) { code, desc, msg in
            if code == 0 {
                debugPrint("modifyMessage,success")
            } else {
                debugPrint("---+++修改消息失败")
            }
        }
    }
    
    //字典转成字符串
    private func dicValueString(_ dic:[String : Any]) -> String?{
        let dicData = try? JSONSerialization.data(withJSONObject: dic, options: [])
        guard let data = dicData else { return nil }
        let str = String(data: data, encoding: String.Encoding.utf8)
        return str
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RoomMessageManager: TUIRoomKitListener {
    func onLogin(code: Int, message: String) {
        if code == 0 {
            TUIRoomKit.sharedInstance.setSelfInfo(userName: TUILogin.getNickName() ?? "", avatarURL: TUILogin.getFaceUrl() ?? "")
            isEngineLogin = true
            sendRoomMessageToGroup()
        }
    }
}

