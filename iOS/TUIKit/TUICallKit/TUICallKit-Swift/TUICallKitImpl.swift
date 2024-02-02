//
//  TUICallKitImpl.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/4.
//

import Foundation
import TUICore
import UIKit
import TUICallEngine

#if USE_TRTC
import TXLiteAVSDK_TRTC
#else
import TXLiteAVSDK_Professional
#endif

class TUICallKitImpl: TUICallKit {
    static let instance = TUICallKitImpl()
    let selfUserCallStatusObserver = Observer()
    
    override init() {
        super.init()
        registerNotifications()
        registerObserveState()
    }
    
    deinit {
        CallEngineManager.instance.removeObserver(TUICallState.instance)
        NotificationCenter.default.removeObserver(self)
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfUserCallStatusObserver)
    }
    
    // MARK: TUICallKit对外接口实现
    override func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        CallEngineManager.instance.setSelfInfo(nickname: nickname, avatar: avatar) {
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
        if  userId.count <= 0 {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userId'")
            return
        }
        
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if WindowManager.instance.isFloating {
            fail(ERROR_PARAM_INVALID, "call failed, Unable to restart the call")
            TUITool.makeToast(TUICallKitLocalize(key: "TUICallKit.UnableToRestartTheCall"))
            return
        }
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if TUICallKitCommon.checkAuthorizationStatusIsDenied(mediaType: callMediaType) {
            showAuthorizationAlert(mediaType: callMediaType)
            fail(ERROR_PARAM_INVALID, "call failed, authorization status is denied")
            return
        }
        
        CallEngineManager.instance.call(userId: userId, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            self.handleAbilityFailErrorMessage(code: code, message: message)
            fail(code, message)
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: getCallParams()) {
            
        } fail: { code, message in
            
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                            succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if  userIdList.isEmpty {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userIdList'")
            return
        }
        
        if userIdList.count >= MAX_USER {
            fail(ERROR_PARAM_INVALID, "groupCall failed, currently supports call with up to 9 people")
            TUITool.makeToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
        
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if WindowManager.instance.isFloating {
            fail(ERROR_PARAM_INVALID, "call failed, Unable to restart the call")
            TUITool.makeToast(TUICallKitLocalize(key: "TUICallKit.UnableToRestartTheCall"))
            return
        }
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        
        if TUICallKitCommon.checkAuthorizationStatusIsDenied(mediaType: callMediaType) {
            showAuthorizationAlert(mediaType: callMediaType)
            fail(ERROR_PARAM_INVALID, "call failed, authorization status is denied")
            return
        }
        
        CallEngineManager.instance.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            self.handleAbilityFailErrorMessage(code: code, message: message)
            fail(code,message)
        }
    }
    
    override func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        if TUICallKitCommon.checkAuthorizationStatusIsDenied(mediaType: callMediaType) {
            showAuthorizationAlert(mediaType: callMediaType)
            return
        }
        
        CallEngineManager.instance.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
            
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            self.handleAbilityFailErrorMessage(code: code, message: message)
        }
    }
    
    override func setCallingBell(filePath: String) {
        if filePath.hasPrefix("http") {
            let session = URLSession.shared
            guard let url = URL(string: filePath) else { return }
            let downloadTask = session.downloadTask(with: url) { location, response, error in
                if error != nil {
                    return
                }
                
                if location != nil {
                    if let oldBellFilePath = UserDefaults.standard.object(forKey: TUI_CALLING_BELL_KEY) as? String {
                        do {
                            try FileManager.default.removeItem(atPath: oldBellFilePath)
                        } catch let error {
                            debugPrint("FileManager Error: \(error)")
                        }
                    }
                    guard let location = location else { return }
                    guard let dstDocPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else { return }
                    let dstPath = dstDocPath + "/" + location.lastPathComponent
                    do {
                        try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: dstPath))
                    } catch let error {
                        debugPrint("FileManager Error: \(error)")
                    }
                    UserDefaults.standard.set(dstPath, forKey: TUI_CALLING_BELL_KEY)
                    UserDefaults.standard.synchronize()
                }
            }
            downloadTask.resume()
        } else {
            UserDefaults.standard.set(filePath, forKey: TUI_CALLING_BELL_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func enableMuteMode(enable: Bool) {
        UserDefaults.standard.set(enable, forKey: ENABLE_MUTEMODE_USERDEFAULT)
        TUICallState.instance.enableMuteMode = enable
    }
    
    override func enableFloatWindow(enable: Bool) {
        TUICallState.instance.enableFloatWindow = enable
    }
    
    override func enableCustomViewRoute(enable: Bool) {
        
    }
    
    override func getCallViewController() -> UIViewController {
        if let callWindowVC = WindowManager.instance.callWindow.rootViewController {
            return callWindowVC
        }
        
        if let floatingWindowVC = WindowManager.instance.floatWindow.rootViewController {
            return floatingWindowVC
        }
        
        return UIViewController()
    }
}

// MARK: TUICallKit内部接口
private extension TUICallKitImpl {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessNotification),
                                               name: NSNotification.Name.TUILoginSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutSuccessNotification),
                                               name: NSNotification.Name.TUILogoutSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showViewControllerNotification),
                                               name: NSNotification.Name(Constants.EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER),
                                               object: nil)
    }
    
    @objc func loginSuccessNotification(noti: Notification) {
        initEngine()
        initState()
        CallEngineManager.instance.addObserver(TUICallState.instance)
        CallEngineManager.instance.setFramework()
        CallEngineManager.instance.setExcludeFromHistoryMessage()
    }
    
    @objc func logoutSuccessNotification(noti: Notification) {
        CallEngineManager.instance.hangup()
        TUICallEngine.destroyInstance()
        TUICallState.instance.cleanState()
    }
    
    @objc func showViewControllerNotification(noti: Notification) {
        TUICallState.instance.audioDevice.value = .earpiece
        CallEngineManager.instance.setAudioPlaybackDevice(device: .earpiece)
        WindowManager.instance.showCallWindow()
    }
    
    func initEngine() {
        CallEngineManager.instance.initEngine(sdkAppId:TUILogin.getSdkAppID(),
                                              userId: TUILogin.getUserID() ?? "",
                                              userSig: TUILogin.getUserSig() ?? "") {} fail: { Int32errCode, errMessage in }
        
        let videoEncoderParams = TUIVideoEncoderParams()
        videoEncoderParams.resolution = ._640_360
        videoEncoderParams.resolutionMode = .portrait
        CallEngineManager.instance.setVideoEncoderParams(params: videoEncoderParams)  {} fail: { Int32errCode, errMessage in }
        
        let videoRenderParams = TUIVideoRenderParams()
        videoRenderParams.fillMode = .fill
        videoRenderParams.rotation = ._0
        CallEngineManager.instance.setVideoRenderParams(userId: TUILogin.getUserID() ?? "",
                                                        params: videoRenderParams) {} fail: { Int32errCode, errMessage in }
        
        let beauty = CallEngineManager.instance.getTRTCCloudInstance().getBeautyManager()
        beauty.setBeautyStyle(.nature)
        beauty.setBeautyLevel(6.0)
    }
    
    func initState() {
        CallEngineManager.instance.addObserver(TUICallState.instance)
        User.getSelfUserInfo(response: { selfUser in
            TUICallState.instance.selfUser.value.id.value = selfUser.id.value
            TUICallState.instance.selfUser.value.nickname.value = selfUser.nickname.value
            TUICallState.instance.selfUser.value.avatar.value = selfUser.avatar.value
        })
    }
    
    func registerObserveState() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfUserCallStatusObserver, closure: { newValue, _ in
            if TUICallState.instance.selfUser.value.callRole.value != TUICallRole.none &&
                TUICallState.instance.selfUser.value.callStatus.value == TUICallStatus.waiting {
                TUICallState.instance.audioDevice.value = TUIAudioPlaybackDevice.earpiece
                CallEngineManager.instance.setAudioPlaybackDevice(device: TUIAudioPlaybackDevice.earpiece)
                WindowManager.instance.showCallWindow()
            }
            
            if TUICallState.instance.selfUser.value.callRole.value == TUICallRole.none &&
                TUICallState.instance.selfUser.value.callStatus.value == TUICallStatus.none {
                WindowManager.instance.closeCallWindow()
                WindowManager.instance.closeFloatWindow()
            }
        })
    }
    
    func showAuthorizationAlert(mediaType: TUICallMediaType) {
        let statusVideo: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        var deniedType: AuthorizationDeniedType = AuthorizationDeniedType.audio
        
        if mediaType == .video && statusVideo == .denied {
            deniedType = .video
        }
        
        TUICallKitCommon.showAuthorizationAlert(deniedType: deniedType) {
            CallEngineManager.instance.hangup()
        } cancelHandler: {
            CallEngineManager.instance.hangup()
        }
    }
    
    func getCallParams() -> TUICallParams {
        let offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        let callParams = TUICallParams()
        callParams.offlinePushInfo = offlinePushInfo
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        return callParams
    }
    
    func convertCallKitError(code: Int32, message: String?) -> String {
        var errorMessage: String? = message
        if code == ERROR_PACKAGE_NOT_PURCHASED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.purchased")
        } else if code == ERROR_PACKAGE_NOT_SUPPORTED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.support")
        } else if code == ERR_SVR_MSG_IN_PEER_BLACKLIST.rawValue {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorInPeerBlacklist")
        } else if code == ERROR_INIT_FAIL {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorInvalidLogin")
        } else if code == ERROR_PARAM_INVALID {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorParameterInvalid")
        } else if code == ERROR_REQUEST_REFUSED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorRequestRefused")
        } else if code == ERROR_REQUEST_REPEATED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorRequestRepeated")
        } else if code == ERROR_SCENE_NOT_SUPPORTED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorSceneNotSupport")
        }
        return errorMessage ?? ""
    }
    
    func handleAbilityFailErrorMessage(code: Int32, message: String?) {
        let errorMessage = TUITool.convertIMError(Int(code), msg: convertCallKitError(code: code, message: message))
        TUITool.makeToast(errorMessage ?? "", duration: 4)
    }
    
}
