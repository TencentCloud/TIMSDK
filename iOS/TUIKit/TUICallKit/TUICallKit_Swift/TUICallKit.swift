//
//  TUICallKit.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import RTCRoomEngine

@objc
public class TUICallKit: NSObject {
    
    /**
     * Create a TUICallKit instance
     */
    @objc
    public static func createInstance() -> TUICallKit {
        return TUICallKitImpl.shared
    }
    
    /**
     * Set user profile
     *
     * @param nickname User name, which can contain up to 500 bytes
     * @param avatar   User profile photo URL, which can contain up to 500 bytes
     * For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
     */
    @objc
    public func setSelfInfo(nickname: String, avatar: String, succ:@escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.shared.setSelfInfo(nickname: nickname, avatar: avatar, succ: succ, fail: fail)
    }
    
    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     */
    @available(*, deprecated, message: "This interface has been deprecated, please use the 'calls' interface.")
    @objc
    public func call(userId: String, callMediaType: TUICallMediaType) {
        return TUICallKitImpl.shared.call(userId: userId, callMediaType: callMediaType)
    }
    
    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    @available(*, deprecated, message: "This interface has been deprecated, please use the 'calls' interface.")
    @objc
    public func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams,
                     succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.shared.call(userId: userId, callMediaType: callMediaType, params: params, succ: succ, fail: fail)
    }
    
    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     */
    @available(*, deprecated, message: "This interface has been deprecated, please use the 'calls' interface.")
    @objc
    public func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        return TUICallKitImpl.shared.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType)
    }
    
    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    @available(*, deprecated, message: "This interface has been deprecated, please use the 'calls' interface.")
    @objc
    public func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                          succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.shared.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params,
                                                 succ: succ, fail: fail)
    }
    
    /**
     * calls
     *
     * @param userIdList    List of userId
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    @objc
    public func calls(userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams?,
                      succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.shared.calls(userIdList: userIdList, callMediaType: callMediaType, params: params,
                                             succ: succ, fail: fail)
    }
  
    /**
     * Join a current call
     *
     * @param callId        current call ID
     * @param callMediaType call type
     */
    @objc
    public func join(callId: String) {
        return TUICallKitImpl.shared.join(callId: callId)
    }
    
    /**
     * Join a current call
     *
     * @param roomId        current call room ID
     * @param callMediaType call type
     */
    @available(*, deprecated, message: "This interface has been deprecated, please use the 'join' interface.")
    @objc
    public func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        return TUICallKitImpl.shared.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType)
    }
    
    /**
     * Set the ringtone (preferably shorter than 30s)
     *
     * @param filePath Callee ringtone path
     */
    @objc
    public func setCallingBell(filePath: String) {
        return TUICallKitImpl.shared.setCallingBell(filePath: filePath)
    }
    
    /**
     * Enable the mute mode (the callee doesn't ring)
     */
    @objc public func enableMuteMode(enable: Bool) {
        return TUICallKitImpl.shared.enableMuteMode(enable: enable)
    }
    
    /**
     * Enable the floating window
     */
    @objc
    public func enableFloatWindow(enable: Bool) {
        return TUICallKitImpl.shared.enableFloatWindow(enable: enable)
    }
    
    /**
     * Enable Virtual Background
     */
    @objc
    public func enableVirtualBackground(enable: Bool) {
        return TUICallKitImpl.shared.enableVirtualBackground(enable: enable)
    }
    
    /**
     * Enable Incoming Banner
     */
    @objc
    public func enableIncomingBanner(enable: Bool) {
        return TUICallKitImpl.shared.enableIncomingBanner(enable: enable)
    }
    
    @objc
    public func callExperimentalAPI(jsonStr: String) {
        TUICallKitImpl.shared.callExperimentalAPI(jsonStr: jsonStr)
    }
}
