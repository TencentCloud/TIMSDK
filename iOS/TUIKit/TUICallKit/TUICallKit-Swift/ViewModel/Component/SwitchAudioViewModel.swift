//
//  SwitchToAudioViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/6.
//

import Foundation

class SwitchAudioViewModel {
    
    func switchToAudio() {
        CallEngineManager.instance.switchToAudio()
    }
}
