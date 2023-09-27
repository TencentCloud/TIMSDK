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
    var videoResolution: TRTCVideoResolution = ._960_540
    var videoBitrate: Int = 900
    var isMirror: Bool = true
    var isFrontCamera: Bool = true
    var videoQuality: TUIVideoQuality = .quality540P
    var bitrate: BitrateTableData = BitrateTableData(resolutionName: "540 * 960",
                                                     resolution: TRTCVideoResolution._960_540,
                                                     defaultBitrate: 900,
                                                     minBitrate: 400,
                                                     maxBitrate: 1_600,
                                                     stepBitrate: 50)
}
