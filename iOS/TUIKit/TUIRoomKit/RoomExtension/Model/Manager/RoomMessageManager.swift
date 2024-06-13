//
//  RoomMessageManager.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//  Manage messages, including sending messages and modifying messages
//

import Foundation
import TUICore
import RTCRoomEngine

class RoomMessageManager: NSObject {
    static let shared = RoomMessageManager()
    private var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    private lazy var userId: String = {
        return TUILogin.getUserID() ?? engineManager.store.currentUser.userId
    }()
    weak var navigateController: UINavigationController?
    var isReadyToSendMessage: Bool = true
    var groupId: String = ""
    private override init() {
        super.init()
        TUICore.registerEvent(TUICore_TUIChatNotify, subKey: TUICore_TUIChatNotify_SendMessageSubKey, object: self)
    }
    
    func sendRoomMessageToGroup() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard BusinessSceneUtil.canJoinRoom() else { return }
            if self.engineManager.store.isEnteredRoom {
                RoomManager.shared.exitOrDestroyPreviousRoom() { [weak self] in
                    guard let self = self else { return }
                    self.sendMessage()
                } onError: { [weak self] code, message in
                    guard let self = self else { return }
                    self.sendMessage()
                    debugPrint("exitRoom,code:\(code),message:\(message)")
                }
            } else {
                self.sendMessage()
            }
        }
    }
    
    private func sendMessage() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.isReadyToSendMessage else {
                self.changeReadyToSendMessage()
                return
            }
            self.isReadyToSendMessage = false
            FetchRoomId.getRoomId { [weak self] roomId in
                guard let self = self else { return }
                let messageModel = RoomMessageModel()
                messageModel.groupId = self.groupId
                messageModel.roomId = roomId
                messageModel.ownerName = TUILogin.getNickName() ?? ""
                messageModel.owner = self.userId
                let messageDic = messageModel.getDictFromMessageModel()
                guard let jsonString = messageDic.convertToString() else { return }
                let jsonData = jsonString.data(using: String.Encoding.utf8)
                let message = V2TIMManager.sharedInstance().createCustomMessage(jsonData)
                message?.supportMessageExtension = true
                let param = [TUICore_TUIChatService_SendMessageMethod_MsgKey: message]
                TUICore.callService(TUICore_TUIChatService, method: TUICore_TUIChatService_SendMessageMethod, param: param as [AnyHashable : Any])
                RoomManager.shared.roomId = roomId
            }
        }
    }
    
    func resendRoomMessage(message: RoomMessageModel,dic:[String: Any]) {
        if message.messageId == "" {
            self.modifyMessage(message: message, dic: dic)
            return
        }
        V2TIMManager.sharedInstance().findMessages([message.messageId]) { [weak self] messageArray in
            guard let self = self else { return }
            guard let array = messageArray else { return }
            for previousMessage in array where previousMessage.msgID == message.messageId {
                self.modifyMessage(message: message, dic: dic)
            }
        } fail: { [weak self] code, messageString in
            guard let self = self else { return }
            self.modifyMessage(message: message, dic: dic)
        }
    }
    
    private func modifyMessage(message: RoomMessageModel, dic:[String: Any]) {
        guard let message = message.getMessage() else { return }
        guard var customElemDic = TUITool.jsonData2Dictionary(message.customElem.data) as? [String: Any] else { return }
        for (key, value) in dic {
            customElemDic[key] = value
        }
        guard let jsonString = customElemDic.convertToString() else { return }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        message.customElem.data = jsonData
        V2TIMManager.sharedInstance().modifyMessage(message) { code, desc, msg in
            if code == 0 {
                debugPrint("modifyMessage,success")
            } else {
                debugPrint("modifyMessage,code:\(code),message:\(String(describing: desc))")
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RoomMessageManager {
    private func changeReadyToSendMessage() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 20) { [weak self] in
            guard let self = self else { return }
            self.isReadyToSendMessage = true
        }
    }
}

extension RoomMessageManager: TUINotificationProtocol {
    func onNotifyEvent(_ key: String, subKey: String, object anObject: Any?, param: [AnyHashable : Any]?) {
        guard key == TUICore_TUIChatNotify, subKey == TUICore_TUIChatNotify_SendMessageSubKey else { return }
        guard let code = param?[TUICore_TUIChatNotify_SendMessageSubKey_Code] as? Int else { return }
        if code == 0 {
            guard let message = param?[TUICore_TUIChatNotify_SendMessageSubKey_Message] as? V2TIMMessage else { return }
            let messageModel = RoomMessageModel()
            messageModel.updateMessage(message: message)
            guard messageModel.messageId.count > 0, messageModel.roomState == .creating, messageModel.roomId == RoomManager.shared.roomId else { return }
            let roomInfo = TUIRoomInfo()
            roomInfo.roomId = messageModel.roomId
            RoomManager.shared.createRoom(roomInfo: roomInfo)
        } else {
            guard let errorMessage = param?[TUICore_TUIChatNotify_SendMessageSubKey_Desc] as? String else { return }
            RoomRouter.makeToast(toast: errorMessage)
        }
    }
}

