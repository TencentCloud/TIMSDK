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
        case destroying //房间正在销毁
        case destroyed //房间已经被销毁
    }
    private var message: V2TIMMessage?
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
    init() {}
    
    func updateMessage(message: V2TIMMessage) {
        self.message = message
        self.messageId = message.msgID ?? ""
        guard var dict = getMessageCustomElemDic(message: message) else { return }
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
        setMessageCustomElemData(dict: dict, message: message)
    }
    
    private func getMessageCustomElemDic(message: V2TIMMessage) -> [String: Any]? {
        guard let dataString = String(data: message.customElem.data, encoding: String.Encoding.utf8) else { return nil }
        guard let data = dataString.data(using: String.Encoding.utf8) else { return nil }
        guard let dict = try? JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String : Any] else { return nil }
        return dict
    }
    
    private func setMessageCustomElemData(dict: [String: Any], message: V2TIMMessage) {
        guard let jsonString = dicValueString(dict) else { return }
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        message.customElem.data = jsonData
    }
    
    func getDictFromMessageModel() -> [String: Any] {
        let dict = ["version": version,
                    "businessID": businessID,
                    "groupId": groupId,
                    "roomId": roomId,
                    "owner": owner,
                    "ownerName": ownerName,
                    "roomState": roomState.rawValue,
                    "memberCount": memberCount,
                    "messageId": messageId,
                    "userList": userList,
        ] as [String : Any]
        return dict
    }
    
    func getMessage() -> V2TIMMessage? {
        return message
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
