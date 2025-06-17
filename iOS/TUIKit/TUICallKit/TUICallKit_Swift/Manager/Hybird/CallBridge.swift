//
//  CallBridge.swift
//  Pods
//
//  Created by vincepzhang on 2025/4/9.
//

import RTCRoomEngine
import TUICore
import RTCCommon

public class CallBridge {
        
    private var floatWindowObservers: [FloatWindowObserver] = []
    
    public init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleTapFloatWindow),
                                               name: NSNotification.Name(EVENT_TAP_FLOATWINDOW),
                                               object: nil)
    }
    
    public func login(sdkAppId: Int32, userId: String, userSig: String, frameWork: Int, component: Int, language: Int, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        Logger.info("CallBridge->login. sdkAppId:\(sdkAppId), userId:\(userId), frameWork:\(frameWork), component:\(component), language:\(language)")
        DispatchQueue.main.async {
            FrameworkConstants.framework = frameWork
            FrameworkConstants.component = component
            FrameworkConstants.language = language
            
            TUILogin.login(sdkAppId, userID: userId, userSig: userSig) {
                Logger.info("CallBridge->login succ.")
                succ()
            } fail: { code, message in
                Logger.error("CallBridge->login fail. code:\(code), message:\(message ?? "")")
                fail(code, message)
            }
        }
    }
    
    public func logout(succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        Logger.info("CallBridge->logout")
        DispatchQueue.main.async {
            TUILogin.logout {
                TRTCLog.info("CallBridge->logout succ.")
                succ()
            } fail: { code, message in
                TRTCLog.error("CallBridge->logout fail. code:\(code), message:\(message ?? "")")
                fail(code, message)
            }
        }
    }
    
    public func calls(userIdList: [String],
                      mediaType: TUICallMediaType,
                      params: TUICallParams,
                      succ: @escaping TUICallSucc,
                      fail: @escaping TUICallFail) {
        Logger.info("CallBridge->calls. userIdList:\(userIdList), mediaType:\(mediaType), params:\(params)")
        DispatchQueue.main.async {
            CallManager.shared.calls(userIdList: userIdList, callMediaType: mediaType, params: params, succ: succ, fail: fail)
        }
    }
    
    public func join(callId: String,
                     succ: @escaping TUICallSucc,
                     fail: @escaping TUICallFail) {
        Logger.info("CallBridge->join. callId:\(callId)")
        DispatchQueue.main.async {
            CallManager.shared.join(callId: callId, succ: succ, fail: fail)
        }
    }
    
    public func inviteUser(userIds: [String],
                           succ: @escaping TUICallSucc,
                           fail: @escaping TUICallFail) {
        Logger.info("CallBridge->inviteUser. userIds:\(userIds)")
        DispatchQueue.main.async {
            CallManager.shared.inviteUser(userIds: userIds, succ: succ, fail: fail)
        }
    }
    
    public func accept(succ: @escaping TUICallSucc,
                       fail: @escaping TUICallFail) {
        Logger.info("CallBridge->accept")
        DispatchQueue.main.async {
            CallManager.shared.accept(succ: succ, fail: fail)
        }
    }
    
    public func reject(succ: @escaping TUICallSucc,
                       fail: @escaping TUICallFail) {
        Logger.info("CallBridge->reject")
        DispatchQueue.main.async {
            CallManager.shared.reject(succ: succ, fail: fail)
        }
    }
    
    public func hangup(succ: @escaping TUICallSucc,
                       fail: @escaping TUICallFail) {
        Logger.info("CallBridge->hangup")
        DispatchQueue.main.async {
            CallManager.shared.hangup(succ: succ, fail: fail)
        }
    }
    
    public func openCamera(succ: @escaping TUICallSucc,
                           fail: @escaping TUICallFail) {
        Logger.info("CallBridge->openCamera")
        DispatchQueue.main.async {
            let videoView = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser)
            CallManager.shared.openCamera(videoView: videoView?.getVideoView() ?? UIView(), succ: succ, fail: fail)
        }
    }

    public func closeCamera() {
        Logger.info("CallBridge->closeCamera")
        DispatchQueue.main.async {
            CallManager.shared.closeCamera()
        }
    }
    
    public func switchCamera(camera: TUICamera) {
        Logger.info("CallBridge->switchCamera. camera:\(camera)")
        DispatchQueue.main.async {
            CallManager.shared.switchCamera(camera: camera)
        }
    }
    
    public func openMicrophone(succ: @escaping TUICallSucc,
                               fail: @escaping TUICallFail) {
        Logger.info("CallBridge->openMicrophone")
        DispatchQueue.main.async {
            CallManager.shared.openMicrophone(succ: succ, fail: fail)
        }
    }
    
    public func closeMicrophone() {
        Logger.info("CallBridge->closeMicrophone")
        DispatchQueue.main.async {
            CallManager.shared.closeMicrophone()
        }
    }
    
    public func selectAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        Logger.info("CallBridge->selectAudioPlaybackDevice. device:\(device)")
        DispatchQueue.main.async {
            CallManager.shared.selectAudioPlaybackDevice(device: device)
        }
    }
    
    public func enableMultiDeviceAbility(enable: Bool, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        Logger.info("CallBridge->enableMultiDeviceAbility. enable:\(enable)")
        DispatchQueue.main.async {
            CallManager.shared.enableMultiDeviceAbility(enable: enable, succ: succ, fail: fail)
        }
    }
    
    public func setSelfInfo(nickName: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        Logger.info("CallBridge->setSelfInfo. nickName:\(nickName), avatar:\(avatar)")
        DispatchQueue.main.async {
            CallManager.shared.setSelfInfo(nickname: nickName, avatar: avatar, succ: succ, fail: fail)
        }
    }
    
    public func setCallingBell(filePath: String) {
        Logger.info("CallBridge->setCallingBell. filePath:\(filePath)")
        DispatchQueue.main.async {
            CallManager.shared.setCallingBell(filePath: filePath)
        }
    }
    
    public func enableMuteMode(enable: Bool) {
        Logger.info("CallBridge->enableMuteMode. enable:\(enable)")
        DispatchQueue.main.async {
            CallManager.shared.enableMuteMode(enable: enable)
        }
    }
    
    public func enableFloatWindow(enable: Bool) {
        Logger.info("CallBridge->enableFloatWindow. enable:\(enable)")
        DispatchQueue.main.async {
            CallManager.shared.enableFloatWindow(enable: enable)
        }
    }
    
    public func enableVirtualBackground(enable: Bool) {
        Logger.info("CallBridge->enableVirtualBackground. enable:\(enable)")
        DispatchQueue.main.async {
            CallManager.shared.enableVirtualBackground(enable: enable)
        }
    }
    
    public func setBlurBackground(level: Int) {
        Logger.info("CallBridge->setBlurBackground. level:\(level)")
        DispatchQueue.main.async {
            CallManager.shared.setBlurBackground(enable: level > 0)
        }
    }
    
    public func startFloatWindow() {
        Logger.info("CallBridge->startFloatWindow")
        DispatchQueue.main.async {
            WindowManager.shared.showFloatingWindow()
        }
    }
    
    public func stopFloatWindow() {
        Logger.info("CallBridge->stopFloatWindow")
        DispatchQueue.main.async {
            WindowManager.shared.closeWindow()
        }
    }
        
    public func addFloatWindowObserver(observer: FloatWindowObserver) {
        Logger.info("CallBridge->addFloatWindowObserver. observer:\(observer)")
        if !floatWindowObservers.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(observer) }) {
            floatWindowObservers.append(observer)
        }
    }
    
    public func removeFloatWindowObserver(observer: FloatWindowObserver) {
        Logger.info("CallBridge->removeFloatWindowObserver. observer:\(observer)")
        floatWindowObservers.removeAll { ObjectIdentifier($0) == ObjectIdentifier(observer) }
    }
    
    public func callExperimentalAPI(jsonStr: String) {
        Logger.info("CallBridge->callExperimentalAPI. jsonStr:\(jsonStr)")
        DispatchQueue.main.async {
            CallManager.shared.callExperimentalAPI(jsonStr: jsonStr)
        }
    }
    
    public func hasPermission(mediaType: TUICallMediaType) -> Bool {
        return Permission.hasPermission(callMediaType: mediaType, fail: nil)
    }
    
    // MARK: Private
    @objc private func handleTapFloatWindow() {
        Logger.info("CallBridge->handleTapFloatWindow")
        for observer in floatWindowObservers {
            observer.tapFloatWindow()
        }
    }
}

public protocol FloatWindowObserver: AnyObject {
    func tapFloatWindow()
}
