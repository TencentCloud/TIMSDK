//
//  FetchRoomId.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/1/29.
//

import Foundation
import TUICore

class FetchRoomId {
    class func getRoomId(onGetRoomId: @escaping (String)->()) {
        let roomId = getRandomRoomId(numberOfDigits: 6)
        checkIfRoomIdExists(roomId: roomId) {
            getRoomId(onGetRoomId: onGetRoomId)
        } onNotExist: {
            onGetRoomId(roomId)
        }
    }
    
    class func getRandomRoomId(numberOfDigits: Int) -> String {
        var numberOfDigit = numberOfDigits > 0 ? numberOfDigits : 1
        numberOfDigit = numberOfDigit < 10 ? numberOfDigit : 9
        let minNumber = Int(truncating: NSDecimalNumber(decimal: pow(10, numberOfDigit - 1)))
        let maxNumber = Int(truncating: NSDecimalNumber(decimal: pow(10, numberOfDigit))) - 1
        let randomNumber = arc4random_uniform(UInt32(maxNumber - minNumber)) + UInt32(minNumber)
        return String(randomNumber)
    }
    
    class func checkIfRoomIdExists(roomId: String, onExist: @escaping () -> (), onNotExist: @escaping () -> ()) {
        V2TIMManager.sharedInstance().getGroupsInfo([roomId]) { infoResult in
            if checkIfRoomIdExistsWithResultCode(infoResult?.first?.resultCode) {
                onExist()
            } else {
                onNotExist()
            }
        } fail: { code, message in
            onNotExist()
        }
    }
    
    private class func checkIfRoomIdExistsWithResultCode(_ resultCode: Int32?) -> Bool {
        let kIMCodeGroupSuccess = 0
        let kIMCodeGroupInsufficientOperationAuthority = 10007
        if let resultCode = resultCode {
            return resultCode == kIMCodeGroupSuccess || resultCode == kIMCodeGroupInsufficientOperationAuthority
        } else {
            return false
        }
    }
}


