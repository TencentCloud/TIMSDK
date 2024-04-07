//
//  RoomMsgViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TIMCommon
import TUICore
import TUIRoomEngine

@objc(RoomMessageBubbleCellData)
class RoomMessageBubbleCellData: TUIBubbleMessageCellData {
    var messageModel: RoomMessageModel?
    override init(direction: TMsgDirection) {
        super.init(direction: direction)
    }
    override class func getCellData(_ message: V2TIMMessage) -> TUIMessageCellData {
        let messageModel = RoomMessageModel()
        messageModel.updateMessage(message: message)
        if messageModel.messageId.count > 0, messageModel.roomState == .creating, messageModel.roomId == RoomManager.shared.roomId {
            RoomManager.shared.roomObserver.messageModel.updateMessage(message: message)
            createRoom(roomId: messageModel.roomId)
        }
        if messageModel.roomId == RoomManager.shared.roomId, messageModel.roomState != .destroyed {
            RoomManager.shared.roomObserver.messageModel.updateMessage(message: message)
        }
        let messageCellData = RoomMessageBubbleCellData(direction: message.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
        messageCellData.messageModel = messageModel
        return messageCellData
    }
    
    override class func getDisplayString(_ message: V2TIMMessage) -> String {
        let businessID = parseBusinessID(message: message)
        if businessID == BussinessID_GroupRoomMessage {
            let dict = TUITool.jsonData2Dictionary(message.customElem.data) as? [String: Any]
            let userName = dict?["ownerName"] as? String ?? ""
            return userName + .quickMeetingText
        } else {
            return super.getDisplayString(message)
        }
    }
    
    private class func parseBusinessID(message: V2TIMMessage?) -> String {
        guard let message = message else { return "" }
        let customData = message.customElem.data
        let dict = TUITool.jsonData2Dictionary(customData)
        guard let businessID = dict?["businessID"] as? String else { return ""}
        return businessID
    }
    
    private class func createRoom(roomId: String) {
        let roomInfo = TUIRoomInfo()
        roomInfo.roomId = roomId
        roomInfo.name = TUILogin.getNickName() ?? (TUILogin.getUserID() ?? "") + .quickMeetingText
        RoomManager.shared.createRoom(roomInfo: roomInfo)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
private extension String {
    static var quickMeetingText: String {
        localized("TUIRoom.video.conference")
    }
}
