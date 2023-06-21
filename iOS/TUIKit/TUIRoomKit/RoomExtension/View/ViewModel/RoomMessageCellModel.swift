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

@objc(RoomMessageCellModel)
class RoomMessageCellModel: TUIBubbleMessageCellData {
    var messageModel: RoomMessageModel?
    var businessID: String?
    var contentView: RoomMessageContentView?
    typealias WeakModel<T> = () -> T?
    static var messageMap: [String: WeakModel<RoomMessageCellModel>] = [:] //消息存储
    override init(direction: TMsgDirection) {
        super.init(direction: direction)
    }
    override class func getCellData(_ message: V2TIMMessage) -> TUIMessageCellData {
        guard let dict = TUITool.jsonData2Dictionary(message.customElem.data) else { return RoomMessageCellModel(
            direction: message.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming) }
        guard let roomId = dict["roomId"] as? String else { return RoomMessageCellModel(
            direction: message.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming) }
        let messageModel = RoomMessageModel(message: message)
        if let cellData = messageMap[roomId] {
            if let cellModel = cellData() {
                cellModel.messageModel = messageModel
                if cellModel.messageModel?.roomId == messageModel.roomId {
                    cellModel.contentView?.viewModel.changeMessage(message: messageModel)
                }
                return cellModel
            }
        }
        let messageCellData = RoomMessageCellModel(direction: message.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
        messageCellData.businessID = messageModel.businessID
        messageCellData.messageModel = messageModel
        let param: [String: AnyHashable] = [TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod_Message: message]
        messageCellData.contentView = TUICore.createObject(TUICore_TUIRoomImAccessFactory, key:
                                                            TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod,
                                                           param: param) as? RoomMessageContentView
        let weakObserver = { [weak messageCellData] in return messageCellData }
        messageMap[roomId] = weakObserver
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
    
    override func contentSize() -> CGSize {
        return CGSize(width: 238, height: 157)
    }
    
    private class func parseBusinessID(message: V2TIMMessage?) -> String {
        guard let message = message else { return "" }
        let customData = message.customElem.data
        let dict = TUITool.jsonData2Dictionary(customData)
        guard let businessID = dict?["businessID"] as? String else { return ""}
        return businessID
    }
    
    func getRoomMessageView(roomId: String) -> UIView? {
        if contentView != nil {
            if let message = messageModel, message.roomId == roomId {
                contentView?.viewModel.changeMessage(message: message)
            }
            return contentView
        }
        let param: [String: AnyHashable] = [TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod_Message: messageModel?.getMessage()]
        guard let view = TUICore.createObject(TUICore_TUIRoomImAccessFactory, key:
                TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod, param: param)
                as? RoomMessageContentView else { return nil }
        contentView = view
        return view
    }
    deinit {
        debugPrint("deinit \(self)")
    }
}
private extension String {
    static var quickMeetingText: String {
        localized("TUIRoom.quick.meeting")
    }
}
