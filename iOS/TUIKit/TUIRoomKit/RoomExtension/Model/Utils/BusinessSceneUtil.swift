//
//  BusinessSceneUtil.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/7/3.
//  Determine the current scene and set the current scene

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
