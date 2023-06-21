//
//  AudioModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/3/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

class AudioModel {
    var captureVolume: Int = 100
    var playVolume: Int = 100
    var volumePrompt: Bool = true
    var isRecord: Bool = false
    var audioQuality: TUIAudioQuality = .default
}
