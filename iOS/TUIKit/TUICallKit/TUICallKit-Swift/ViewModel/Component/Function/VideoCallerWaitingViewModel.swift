//
//  VideoCallerWaitingViewModel.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import TUICallEngine

class VideoCallerWaitingViewModel {
    
    // MARK: CallEngine Method
    func hangup() {
        CallEngineManager.instance.hangup()
    }

    func switchCamera() {
        CallEngineManager.instance.switchCamera()
    }
}
