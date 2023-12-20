//
//  VideoModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/3/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

class VideoModel {
    var isCameraOpened: Bool = true
    var videoFps: Int = 15
    var videoBitrate: Int = 1_200
    var isMirror: Bool = true
    var isFrontCamera: Bool = true
    var videoQuality: TUIVideoQuality = .quality720P
}
