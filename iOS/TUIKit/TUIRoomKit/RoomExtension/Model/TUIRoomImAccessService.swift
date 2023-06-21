//
//  TUIRoomImAccessService.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/2.
//

import Foundation
import TUICore

class TUIRoomImAccessService: NSObject, TUIServiceProtocol  {
    static let shared = TUIRoomImAccessService()
    var alreadyShownRoomInviteView: Bool = false
    weak var inviteViewController: UIViewController? //邀请页面controller
    var inviteWindow: UIWindow?
    private override init() {
        super.init()
        initRoomMessage()
        initSignalingListener()
    }
    func initRoomMessage() {
        TUICore.callService(TUICore_TUIChatService, method: TUICore_TUIChatService_AppendCustomMessageMethod, param:
                                [BussinessID: BussinessID_GroupRoomMessage, TMessageCell_Name: "RoomMessageCell",
                      TMessageCell_Data_Name:"RoomMessageCellModel",])
    }
    func initSignalingListener() {
        V2TIMManager.sharedInstance().addSignalingListener(listener: self)
    }
    //字符串转成字典
    private func stringToDic(_ str: String) -> [String : Any]?{
        guard let data = str.data(using: String.Encoding.utf8) else { return nil }
        if let dict = try? JSONSerialization.jsonObject(with: data,
                                                        options: .mutableContainers) as? [String : Any] {
            return dict
        }
        
        return nil
    }
}

extension TUIRoomImAccessService: V2TIMSignalingListener {
    //收到了邀请的消息通知
    func onReceiveNewInvitation(_ inviteID: String, inviter: String, groupID: String, inviteeList: [String], data: String?) {
        guard let data = data else { return }
        let dict = stringToDic(data)
        guard let businessID = dict?["businessID"] as? String else { return }
        guard businessID == "ROOM_INVITE_ACTION" else { return }
        guard let roomId = dict?["roomId"] as? String else { return }
        guard let userId = TUILogin.getUserID() else { return }
        let dataDic = dict?["data"] as? NSDictionary ?? [:]
        let inviter = dataDic["inviter"] as? NSDictionary ?? [:]
        let avatarUrl = inviter["avatarUrl"] as? String ?? ""
        let inviterUserName = inviter["userName"] as? String ?? ""
        guard inviteeList.contains(userId) else { return }
            let businessScene = TUILogin.getCurrentBusinessScene()
            guard businessScene == .None || businessScene == .InMeetingRoom else { return }
            showRoomInviteView(inviterUserName: inviterUserName, inviteUserAvatarUrl: avatarUrl, roomId: roomId)
    }
    private func showRoomInviteView(inviterUserName: String, inviteUserAvatarUrl: String, roomId: String) {
        if alreadyShownRoomInviteView {
            return
        }
        alreadyShownRoomInviteView = true
        let inviteViewController = RoomInviteViewController(inviteUserName: inviterUserName,inviteUserAvatarUrl: inviteUserAvatarUrl, roomId: roomId)
        let nav = UINavigationController(rootViewController: inviteViewController)
        nav.setNavigationBarHidden(true, animated: true)
        inviteWindow = UIWindow(frame: UIScreen.main.bounds)
        inviteWindow?.windowLevel = .alert - 1
        guard let inviteWindow = inviteWindow else { return }
        inviteWindow.rootViewController = nav
        inviteWindow.isHidden = false
        inviteWindow.makeKeyAndVisible()
    }
}
