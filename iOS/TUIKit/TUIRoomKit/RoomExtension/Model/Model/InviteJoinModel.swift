//
//  InviteJoinModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/3.
//  邀请其他人进入房间的信令Model

import Foundation
import TUICore
import TUIRoomEngine

class InviteJoinModel {
    private var message: RoomMessageModel
    private var inviter: TUILoginUserInfo
    var platform: String = "iOS"
    var version: Int = 1
    var businessID: String = "ROOM_INVITE_ACTION"
    var roomId: String = ""
    var extInfo: String = ""
    var data: [String:Any] = [:]
    
    init(message: RoomMessageModel, inviter: TUILoginUserInfo) {
        self.message = message
        self.inviter = inviter
        self.roomId = message.roomId
        self.data = getInviteJoinModelDataDic()
    }
    
    func getDicFromInviteJoinModel(inviteJoinModel: InviteJoinModel) -> [String: Any] {
        guard let dict = ["platform": inviteJoinModel.platform,
                          "version": inviteJoinModel.version,
                          "businessID": inviteJoinModel.businessID,
                          "roomId": inviteJoinModel.roomId,
                          "extInfo": inviteJoinModel.extInfo,
                          "data": inviteJoinModel.data,
        ] as? [String: Any] else { return [:] }
        return dict
    }
    
    private func getInviteJoinModelDataDic() -> [String: Any] {
        let messageDic = message.getDictFromMessageModel()
        let inviterDic = getInviterUserInfoDic(inviter: inviter)
        return ["inviter":inviterDic, "roomInfo": messageDic]
    }
    
    private func getInviterUserInfoDic(inviter: TUILoginUserInfo) -> [String: Any] {
        return ["avatarUrl": inviter.avatarUrl,
                "userId": inviter.userId,
                "userName": inviter.userName,
        ]
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
