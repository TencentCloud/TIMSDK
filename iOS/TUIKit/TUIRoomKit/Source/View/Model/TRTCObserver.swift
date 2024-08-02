//
//  TRTCObserver.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/4/1.
//

import Foundation
#if canImport(TXLiteAVSDK_TRTC)
    import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
    import TXLiteAVSDK_Professional
#endif

class TRTCObserver: NSObject, TRTCCloudDelegate {
    var roomId: String {
        EngineManager.shared.store.roomInfo.roomId
    }
    func onExitRoom(_ reason: Int) {
        guard reason == 2 else { return }
        EngineEventCenter.shared.notifyEngineEvent(event: .onRoomDismissed, param: ["roomId": roomId])
    }
    
    func onStatistics(_ statistics: TRTCStatistics) {
        EngineEventCenter.shared.notifyEngineEvent(event: .onStatistics, param: ["statistics": statistics])
    }
}
