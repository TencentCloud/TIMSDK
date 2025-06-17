//
//  TUICallKitImpl.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/4.
//

import Foundation
import TUICore
import UIKit
import RTCRoomEngine
import RTCCommon

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class TUICallKitImpl: TUICallKit {
    static let shared = TUICallKitImpl()
    private let callStatusObserver = Observer()
    
    override init() {
        super.init()
        registerNotifications()
        let _ = CallManager.shared
    }
    
    deinit {
        unregisterNotifications()
    }
        
    // MARK: Implementation of external interface for TUICallKit
    override func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        CallManager.shared.setSelfInfo(nickname: nickname, avatar: avatar) {
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    override func call(userId: String, callMediaType: TUICallMediaType) {
        call(userId: userId, callMediaType: callMediaType, params: getCallParams()) {
            
        } fail: { errCode, errMessage in
            
        }
    }
    
    override func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams,
                       succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if userId == TUILogin.getUserID() {
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.calNotCallYourself"))
            fail(ERROR_INIT_FAIL, "call failed, not to call self")
            return
        }
        
        if  userId.count <= 0 || userId == TUILogin.getUserID() {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userId'")
            return
        }
        
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermission(callMediaType: callMediaType, fail: fail) { return }
        
        CallManager.shared.call(userId: userId, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code, message)
        }
    }
    
    override func calls(userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams?,
                        succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if userIdList.count == 1 && userIdList.first == TUILogin.getUserID() {
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.calNotCallYourself"))
            fail(ERROR_INIT_FAIL, "call failed, not to call self")
            return
        }
        
        let userIdList = userIdList.filter { $0 != TUILogin.getUserID() }
        
        if userIdList.isEmpty {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userIdList'")
            return
        }
        
        if userIdList.count >= MAX_USER {
            fail(ERROR_PARAM_INVALID, "groupCall failed, currently supports call with up to 9 people")
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermission(callMediaType: callMediaType, fail: fail) { return }
        
        CallManager.shared.calls(userIdList: userIdList, callMediaType: callMediaType, params: params ?? getCallParams()) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code,message)
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: getCallParams()) {
            
        } fail: { code, message in
            
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                            succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        let userIdList = userIdList.filter { $0 != TUILogin.getUserID() }
        
        if userIdList.isEmpty {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userIdList'")
            return
        }
        
        if userIdList.count >= MAX_USER {
            fail(ERROR_PARAM_INVALID, "groupCall failed, currently supports call with up to 9 people")
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermission(callMediaType: callMediaType, fail: fail) { return }
        
        CallManager.shared.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code,message)
        }
    }
    
    override func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        if !Permission.hasPermission(callMediaType: callMediaType, fail: nil) { return }
        
        CallManager.shared.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
            
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
        }
    }
    
    override public func join(callId: String) {
        CallManager.shared.join(callId: callId) {
            
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
        }
    }
    
    override func setCallingBell(filePath: String) {
        CallManager.shared.setCallingBell(filePath: filePath)
    }
    
    override func enableMuteMode(enable: Bool) {
        CallManager.shared.enableMuteMode(enable: enable)
    }
    
    override func enableFloatWindow(enable: Bool) {
        CallManager.shared.enableFloatWindow(enable: enable)
    }
    
    override func enableVirtualBackground (enable: Bool) {
        CallManager.shared.enableVirtualBackground(enable: enable)
    }
    
    override func enableIncomingBanner (enable: Bool) {
        CallManager.shared.enableIncomingBanner(enable: enable)
    }
    
    
    override public func callExperimentalAPI(jsonStr: String) {
        CallManager.shared.callExperimentalAPI(jsonStr: jsonStr)
    }
    
    // MARK: Notifications
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCallKitViewController),
                                               name: NSNotification.Name(EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeCallKitViewController),
                                               name: NSNotification.Name(EVENT_CLOSE_TUICALLKIT_VIEWCONTROLLER),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleShowToast(_:)),
                                               name: NSNotification.Name(rawValue: EVENT_SHOW_TOAST),
                                               object: nil)

        
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .accept && CallManager.shared.viewState.router.value == .banner {
                self.showCallKitViewController()
            }
        }
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(EVENT_CLOSE_TUICALLKIT_VIEWCONTROLLER), object: nil)
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
    }
    
    @objc func showCallKitViewController() {
        if CallManager.shared.globalState.enableIncomingBanner == true && CallManager.shared.userState.selfUser.callRole.value == .called &&
            CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            WindowManager.shared.showIncomingBannerWindow()
            return
        }
        WindowManager.shared.showCallingWindow()
    }
    
    @objc func closeCallKitViewController() {
        WindowManager.shared.closeWindow()
    }
    
    @objc func handleShowToast(_ notification: Notification) {
        guard let data = notification.object as? String else { return }
        Toast.shared.showToast(message: data)
    }
    
    // MARK: other private
    private func getCallParams() -> TUICallParams {
        let offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        let callParams = TUICallParams()
        callParams.offlinePushInfo = offlinePushInfo
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        return callParams
    }
}
