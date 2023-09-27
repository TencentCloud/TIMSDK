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
    var isMicDeviceOpened: Bool = false //是否已打开麦克风设备
    var isMicOpened: Bool = true //进房前选择是否打开麦克风状态
    var isSoundOnSpeaker: Bool = true
    var captureVolume: Int = 100
    var playVolume: Int = 100
    var volumePrompt: Bool = true
    var isRecord: Bool = false
    var audioQuality: TUIAudioQuality = .default
}
