//
//  TUICallKit.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import TUICallEngine

public class TUICallKit {
    
    /**
     * Create a TUICallKit instance 
     */
    public static func createInstance() -> TUICallKit {
        return TUICallKitImpl.instance
    }

    /**
     * Set user profile
     *
     * @param nickname User name, which can contain up to 500 bytes
     * @param avatar   User profile photo URL, which can contain up to 500 bytes
     * For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
     *
     */
    public func setSelfInfo(nickname: String, avatar: String, succ:@escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.instance.setSelfInfo(nickname: nickname, avatar: avatar, succ: succ, fail: fail)
    }
    
    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     */
    public func call(userId: String, callMediaType: TUICallMediaType) {
        return TUICallKitImpl.instance.call(userId: userId, callMediaType: callMediaType)
    }

    /**
     * Make a call
     *
     * @param userId        callees
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    public func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams,
                     succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.instance.call(userId: userId, callMediaType: callMediaType, params: params, succ: succ, fail: fail)
    }

    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     */
    public func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        return TUICallKitImpl.instance.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType)
    }
    
    /**
     * Make a group call
     *
     * @param groupId       GroupId
     * @param userIdList    List of userId
     * @param callMediaType Call type
     * @param params        Extension param: eg: offlinePushInfo
     */
    public func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                          succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        return TUICallKitImpl.instance.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params,
                                                 succ: succ, fail: fail)
    }
    
    /**
     * Join a current call
     *
     * @param roomId        current call room ID
     * @param callMediaType call type
     */
    public func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        return TUICallKitImpl.instance.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType)
    }
    
    /**
     * Set the ringtone (preferably shorter than 30s)
     *
     * @param filePath Callee ringtone path
     */
    public func setCallingBell(filePath: String) {
        return TUICallKitImpl.instance.setCallingBell(filePath: filePath)
    }
    
    /**
     * Enable the mute mode (the callee doesn't ring)
     */
    public func enableMuteMode(enable: Bool) {
        return TUICallKitImpl.instance.enableMuteMode(enable: enable)
    }
    
    /**
     * Enable the floating window
     */
    public func enableFloatWindow(enable: Bool) {
        return TUICallKitImpl.instance.enableFloatWindow(enable: enable)
    }
    
    /**
     * Support custom View
     */
    public func enableCustomViewRoute(enable: Bool) {
        return TUICallKitImpl.instance.enableCustomViewRoute(enable: enable)
    }
    
    /**
     * Get TUICallKit ViewController
     */
    public func getCallViewController() -> UIViewController {
        return TUICallKitImpl.instance.getCallViewController()
    }
}
