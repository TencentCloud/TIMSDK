//
//  VideoModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/3/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

class VideoModel {
    var isCameraOpened: Bool = true
    var videoFps: Int = 15
    var videoBitrate: Int = 1_200
    var isMirror: Bool = true
    var isFrontCamera: Bool = true
    var videoQuality: TUIVideoQuality = .quality720P
}
