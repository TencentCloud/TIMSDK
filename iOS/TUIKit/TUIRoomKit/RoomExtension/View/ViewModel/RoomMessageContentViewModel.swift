//
//  RoomMessageContentViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
import TUICore
import TIMCommon

protocol RoomMessageContentViewResponder: NSObject {
    func updateStackView()
    func updateRoomStatus()
}

class RoomMessageContentViewModel: NSObject {
    var message: RoomMessageModel
    lazy var userList: [[String: Any]] = {
        return message.userList
    }()
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
    var messageManager: RoomMessageManager {
        RoomMessageManager.shared
    }
    let roomKit = TUIRoomKit.sharedInstance
    weak var viewResponder: RoomMessageContentViewResponder?
    init(message: RoomMessageModel) {
        self.message = message
        super.init()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    func changeMessage(message: RoomMessageModel) {
        self.message = message
        userList = message.userList
        viewResponder?.updateStackView()
        viewResponder?.updateRoomStatus()
    }
    
    func initRoomListener() {
        if self.message.owner == self.userId, self.message.roomState != .destroyed {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                guard let self = self else { return }
                self.roomEngine.addObserver(self)
                self.roomKit.addListener(listener: self)
                self.messageManager.addListener(listener: self)
                if self.message.roomState == .creating {
                    self.createRoom()
                }
            }
        }
    }
    
    func createRoom() {
        let roomInfo = RoomInfo()
        roomInfo.roomId = self.message.roomId
        roomInfo.name = TUILogin.getNickName() ?? TUILogin.getUserID() + .quickMeetingText
        roomInfo.speechMode = .freeToSpeak
        roomKit.banAutoRaiseUiOnce(isBan: true)
        roomKit.createRoom(roomInfo: roomInfo, type: .meeting)
    }
    
    private func getUserList(nextSequence: Int) {
        roomEngine.getUserList(nextSequence: nextSequence) { [weak self] list, nextSequence in
            guard let self = self else { return }
            list.forEach { userInfo in
                self.addUserList(userInfo: userInfo)
            }
            if nextSequence != 0 {
                self.getUserList(nextSequence: nextSequence)
            }
        } onError: { code, message in
            debugPrint("getUserList:code:\(code),message:\(message)")
        }
    }
    
    private func addUserList(userInfo: TUIUserInfo) {
        if getUserItem(userInfo.userId) == nil {
            let userDic: [String: Any] = ["userId":userInfo.userId,"userName":userInfo.userName,"faceUrl": userInfo.avatarUrl]
            userList.append(userDic)
        }
    }
    
    private func getUserItem(_ userId: String) -> String? {
        for userDic in userList {
            if let userIdString = userDic["userId"] as? String, userIdString == userId {
                return userIdString
            }
        }
        return nil
    }
    
    func enterRoomAction() {
        //首先判断现在是否已经进行TUICallKit的视频通话或者音频通话
        let businessScene = TUILogin.getCurrentBusinessScene()
        guard businessScene == .InMeetingRoom || businessScene == .None else {
            return
        }
        if !messageManager.isEngineLogin {
            roomKit.addListener(listener: self)
            roomKit.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID(), userSig: TUILogin.getUserSig())
            return
        }
        //如果用户已经进入了其他TUIRoomKit房间，需要先退出房间
        if roomInfo.roomId != message.roomId && roomInfo.roomId != "" {
            messageManager.exitOrDestroyPreviousRoom { [weak self] in
                guard let self = self else { return }
                self.enterRoom()
            } onError: { code, message in
                debugPrint("exitRoom,code:\(code),message:\(message)")
            }
        } else {
            enterRoom()
        }
    }
    
    private func enterRoom() {
        if message.owner != userId {
            roomKit.addListener(listener: self)
            roomEngine.addObserver(self)
        }
        roomKit.setChatAccessRoom(isChatAccessRoom: true)
        let roomInfo = RoomInfo()
        roomInfo.roomId = message.roomId
        roomKit.enterRoom(roomInfo: roomInfo)
    }
    
    func inviteUserAction() {
        if message.groupId.count > 0 {
            let param = [TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID: message.groupId]
            if let navigateController = messageManager.navigateController {
                navigateController.push(TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic, param: param) { [weak self] responseData in
                    guard let self = self else { return }
                    guard let modelList =
                        responseData[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList] as? [TUIUserModel]
                    else { return }
                    self.startInviteUsers(groupId : self.message.groupId, userModelList: modelList, roomId : self.message.roomId)
                }
            } else {
                let nav = UINavigationController()
                let currentViewController = getCurrentWindowViewController()
                currentViewController?.present(TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic,
                                               param: param, embbedIn: nav,
                                               forResult: { [weak self] responseData in
                    guard let self = self else { return }
                    guard let modelList =
                        responseData[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList] as? [TUIUserModel]
                    else { return }
                    self.startInviteUsers(groupId : self.message.groupId, userModelList: modelList, roomId : self.message.roomId)
                })
            }
        }
    }
    
    private func startInviteUsers(groupId: String, userModelList:[TUIUserModel], roomId: String) {
        var userIds: [String] = []
        for userModel in userModelList {
            userIds.append(userModel.userId)
        }
        let roomInfoDic = ["version":1,
                           "businessID": BussinessID_GroupRoomMessage,
                           "groupId": groupId,
                           "roomId": roomId,
                           "owner": message.owner,
                           "ownerName": message.ownerName,
                           "roomState": message.roomState.rawValue,
                           "memberCount": message.memberCount,
                           "messageId": message.messageId,
                           "userList": message.userList,
        ] as [String : Any]
        let inviter = ["avatarUrl":TUILogin.getFaceUrl() ?? "", "userId": userId, "userName": TUILogin.getNickName() ?? ""]
        let dataDic = ["inviter": inviter, "roomInfo":roomInfoDic]
        let param = ["platform":"iOS",
                     "version":1,
                     "businessID":"ROOM_INVITE_ACTION",
                     "roomId":self.roomInfo.roomId,
                     "extInfo":"",
                     "data" : dataDic,] as [String : Any]
        let data = self.dicValueString(param)
        let pushInfo = V2TIMOfflinePushInfo()
        userIds.forEach { userId in
            V2TIMManager.sharedInstance().invite(userId,
                                                 data: data,
                                                 onlineUserOnly: true,
                                                 offlinePushInfo: pushInfo,
                                                 timeout: 60) {
                debugPrint("invite,success")
            } fail: { code, message in
                debugPrint("invite,code:\(code),message:\(String(describing: message))")
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
    //字符串转成字典
   private func stringValueDic(_ str: String) -> [String : Any]?{
        guard let data = str.data(using: String.Encoding.utf8) else { return nil }
        if let dict = try? JSONSerialization.jsonObject(with: data,
                        options: .mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    private func getCurrentWindowViewController() -> UIViewController? {
        var keyWindow: UIWindow?
        for window in UIApplication.shared.windows {
            if window.isMember(of: UIWindow.self), window.isKeyWindow {
                keyWindow = window
                break
            }
        }
        guard let rootController = keyWindow?.rootViewController else {
            return nil
        }
        func findCurrentController(from vc: UIViewController?) -> UIViewController? {
            if let nav = vc as? UINavigationController {
                return findCurrentController(from: nav.topViewController)
            } else if let tabBar = vc as? UITabBarController {
                return findCurrentController(from: tabBar.selectedViewController)
            } else if let presented = vc?.presentedViewController {
                return findCurrentController(from: presented)
            }
            return vc
        }
        let viewController = findCurrentController(from: rootController)
        return viewController
    }
}

extension RoomMessageContentViewModel: TUIRoomObserver {
    func onRemoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        addUserList(userInfo: userInfo)
        if self.message.owner == self.userId {
            let prefixUserList = Array(userList.prefix(5))
                messageManager.resendRoomMessage(message: message, dic: ["userList":prefixUserList,"memberCount":userList.count])
            debugPrint("---+++:,现在上传的userList是：\(prefixUserList.count),memberCount:\(userList.count)")
        }
        viewResponder?.updateStackView()
    }
    func onRemoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        userList = userList.filter { userDic in
            if let userId = userDic["userId"] as? String, userId != userInfo.userId {
                return true
            }
            return false
        }
        if message.owner == userId {
            let prefixUserList = Array(userList.prefix(5))
            messageManager.resendRoomMessage(message: message, dic: ["memberCount":userList.count,"userList":prefixUserList])
            debugPrint("---+++222222:,现在上传的userList是：\(prefixUserList.count),memberCount:\(userList.count)")
        }
        viewResponder?.updateStackView()
    }
    func onUserRoleChanged(userId: String, userRole: TUIRole) {
        if userId == userId, userRole == .roomOwner {
            messageManager.resendRoomMessage(message: message, dic: ["owner": userId])
        }
    }
}

extension RoomMessageContentViewModel: TUIRoomKitListener {
    func onLogin(code: Int, message: String) {
        messageManager.isEngineLogin = true
        enterRoomAction()
    }
    func onRoomCreate(code: Int, message: String) {
        if code == 0 {
            self.message.roomState = .created
            if self.message.owner == userId {
                let userInfo = TUIUserInfo()
                userInfo.userId = userId
                userInfo.avatarUrl = TUILogin.getFaceUrl() ?? ""
                userInfo.userName = TUILogin.getNickName() ?? ""
                addUserList(userInfo: userInfo)
                if self.message.owner == self.userId {
                    let prefixUserList = Array(userList.prefix(5))
                    messageManager.resendRoomMessage(message: self.message, dic: ["userList":prefixUserList,
                                            "memberCount":userList.count,
                                            "roomState":RoomMessageModel.RoomState.created.rawValue,])
                    debugPrint("---+++:,现在上传的userList是：\(prefixUserList.count),memberCount:\(userList.count)")
                }
                viewResponder?.updateRoomStatus()
                viewResponder?.updateStackView()
            }
        }
        messageManager.isReadyToSendMessage = true
    }
    func onRoomEnter(code: Int, message: String) {
        if code == 0 {
            TUILogin.setCurrentBusinessScene(.InMeetingRoom)
            if self.message.owner != userId {
                getUserList(nextSequence: 0)
            }
            if self.message.owner == self.userId {
                let prefixUserList = Array(userList.prefix(5))
                messageManager.resendRoomMessage(message: self.message, dic: ["userList":prefixUserList,"memberCount":userList.count])
                debugPrint("---+++:,现在上传的userList是：\(prefixUserList.count),memberCount:\(userList.count)")
            }
            self.message.roomState = .entered
            viewResponder?.updateRoomStatus()
            if self.message.owner != userId {
                roomEngine.addObserver(self)
                roomKit.addListener(listener: self)
            }
        }
        messageManager.isReadyToSendMessage = true
    }
    func onExitRoom() {
        TUILogin.setCurrentBusinessScene(.None)
        userList = userList.filter { userDic in
            if let userId = userDic["userId"] as? String, userId != userId {
                return true
            }
            return false
        }
        if message.owner == userId {
            let prefixUserList = Array(userList.prefix(5))
            messageManager.resendRoomMessage(message: message, dic: ["userList":prefixUserList, "memberCount":userList.count])
            debugPrint("---+++333333:,现在上传的userList是：\(prefixUserList.count)")
        }
        viewResponder?.updateStackView()
        roomEngine.removeObserver(self)
        roomKit.removeListener()
    }
    func onDestroyRoom() {
        TUILogin.setCurrentBusinessScene(.None)
        self.message.roomState = .destroyed
        if self.message.owner == userId {
            messageManager.resendRoomMessage(message: message, dic: ["roomState":RoomMessageModel.RoomState.destroyed.rawValue])
        }
        viewResponder?.updateRoomStatus()
        roomKit.removeListener()
        messageManager.removeListener()
        roomEngine.removeObserver(self)
    }
}

extension RoomMessageContentViewModel: RoomMessageManagerListener {
    func roomHasDestroyed(roomId: String) {
        if roomId == message.roomId {
            TUILogin.setCurrentBusinessScene(.None)
            self.message.roomState = .destroyed
            if self.message.owner == userId {
                messageManager.resendRoomMessage(message: message, dic: ["roomState":RoomMessageModel.RoomState.destroyed.rawValue])
            }
            viewResponder?.updateRoomStatus()
            roomKit.removeListener()
            engineManager.roomEngine.removeObserver(self)
            messageManager.removeListener()
        }
    }
}
private extension String {
    static var quickMeetingText: String {
        localized("TUIRoom.quick.meeting")
    }
}
