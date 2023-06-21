//
//  RoomMessageModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/10.
//

import Foundation
import TUICore
import TUIRoomEngine

class RoomMessageModel {
    enum RoomState: String {
        case creating//房间正在创建
        case created //房间创建成功
        case entered //进入房间成功
        case destroying //房间进入成功
        case destroyed //房间已经被销毁
    }
    private var message: V2TIMMessage
    var version: Int = 1
    var businessID: String = BussinessID_GroupRoomMessage
    var groupId: String = ""
    var messageId: String = ""
    var roomId: String = ""
    var owner: String = "" //房主的id
    var ownerName: String = ""//房主的昵称
    var roomState: RoomState = .creating //房间状态
    var memberCount: Int = 0
    var userList: [[String:Any]] = []
    init(message: V2TIMMessage) {
        self.message = message
        self.messageId = message.msgID ?? ""
        guard let dataString = String(data: message.customElem.data, encoding: String.Encoding.utf8) else { return }
        guard let data = dataString.data(using: String.Encoding.utf8) else { return }
        guard var dict = try? JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String : Any] else { return }
        self.version = dict["version"] as? Int ?? 1
        self.businessID = dict["businessID"] as? String ?? BussinessID_GroupRoomMessage
        self.groupId = dict["groupId"] as? String ?? ""
        self.roomId = dict["roomId"] as? String ?? ""
        self.owner = dict["owner"] as? String ?? ""
        self.ownerName = dict["ownerName"] as? String ?? ""
        if let roomState = dict["roomState"] as? String {
            self.roomState = RoomState(rawValue: roomState) ?? .creating
        } else {
            self.roomState = .creating
        }
        self.userList = dict["userList"] as? [[String:Any]] ?? []
        self.memberCount = dict["memberCount"] as? Int ?? userList.count
        //需要把messageId赋值进customElem中
        dict["messageId"] = self.messageId
        guard let jsonString = dicValueString(dict) else { return }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        message.customElem.data = jsonData
    }
    //字典转成字符串
    func dicValueString(_ dic:[String : Any]) -> String?{
        let dicData = try? JSONSerialization.data(withJSONObject: dic, options: [])
        guard let data = dicData else { return nil }
        let str = String(data: data, encoding: String.Encoding.utf8)
        return str
    }
    func getMessage() -> V2TIMMessage {
        return message
    }
    deinit {
        debugPrint("deinit \(self)")
    }
}
