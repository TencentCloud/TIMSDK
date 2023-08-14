//
//  BusinessSceneUtil.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/3.
//  判断当前场景以及设置当前场景

import Foundation
import TUICore

class BusinessSceneUtil {
    class func canJoinRoom() -> Bool {
        let businessScene = TUILogin.getCurrentBusinessScene()
        return businessScene == .InMeetingRoom || businessScene == .None
    }
    
    class func setJoinRoomFlag() {
        TUILogin.setCurrentBusinessScene(.InMeetingRoom)
    }
    
    class func clearJoinRoomFlag() {
        TUILogin.setCurrentBusinessScene(.None)
    }
}
