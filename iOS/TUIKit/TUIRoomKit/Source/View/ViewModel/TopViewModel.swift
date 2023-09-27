//
//  TopViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/12/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

protocol TopViewModelResponder: AnyObject {
    func updateTimerLabel(text: String)
}

class TopViewModel {
    private var topMenuTimer: Timer = Timer()
    private(set) var viewItems: [ButtonItemData] = []
    var engineManager: EngineManager {
        return EngineManager.createInstance()
    }
    var store: RoomStore {
        return engineManager.store
    }
    weak var viewResponder: TopViewModelResponder?
    
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    
    init() {
        createBottomData()
        initialStatus()
    }
    
    func createBottomData() {
        let micItem = ButtonItemData()
        micItem.normalIcon = "room_earpiece"
        micItem.selectedIcon = "room_speakerphone"
        micItem.backgroundColor = UIColor(0xA3AEC7)
        micItem.resourceBundle = tuiRoomKitBundle()
        micItem.isSelect = engineManager.store.audioSetting.isSoundOnSpeaker
        micItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.micItemAction(sender: button)
        }
        viewItems.append(micItem)
        let cameraItem = ButtonItemData()
        cameraItem.normalIcon = "room_switch_camera"
        cameraItem.backgroundColor = UIColor(0xA3AEC7)
        cameraItem.resourceBundle = tuiRoomKitBundle()
        cameraItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.cameraItemAction(sender: button)
        }
        viewItems.append(cameraItem)
    }
    
    func initialStatus() {
        if engineManager.store.audioSetting.isSoundOnSpeaker {
            engineManager.setAudioRoute(route: .modeSpeakerphone)
        } else {
            engineManager.setAudioRoute(route: .modeEarpiece)
        }
    }
    
    func micItemAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            engineManager.setAudioRoute(route: .modeSpeakerphone)
        } else {
            engineManager.setAudioRoute(route: .modeEarpiece)
        }
    }
    
    func cameraItemAction(sender: UIButton) {
        engineManager.switchCamera()
    }
    
    func mirrorItemAction(sender: UIButton) {
        engineManager.switchMirror()
    }
    
    func dropDownAction(sender: UIView) {
        RoomRouter.shared.presentPopUpViewController(viewType: .roomInfoViewType, height: 258)
    }
    
    func exitAction(sender: UIView) {
        RoomRouter.shared.presentPopUpViewController(viewType: .exitRoomViewType, height: 219,backgroundColor: UIColor(0x17181F))
    }
    
    func updateTimerLabelText() {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        var totalSeconds: UInt = UInt(labs(timeStamp - store.timeStampOnEnterRoom))
        updateTimer(totalSeconds: totalSeconds)
        topMenuTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            totalSeconds += 1
            self.updateTimer(totalSeconds: totalSeconds)
        }
        topMenuTimer.tolerance = 0.2
        RunLoop.current.add(topMenuTimer, forMode: .default)
        topMenuTimer.fire()
    }
    
    private func updateTimer(totalSeconds: UInt) {
        let second: UInt = totalSeconds % 60
        let minute: UInt = (totalSeconds / 60) % 60
        let hour: UInt = totalSeconds / 3_600
        var timerText: String
        if hour > 0 {
            timerText = String(format: "%.2d:%.2d:%.2d", hour, minute, second)
        } else {
            timerText = String(format: "%.2d:%.2d", minute, second)
        }
        self.viewResponder?.updateTimerLabel(text: timerText)
    }
    
    deinit {
        topMenuTimer.invalidate()
        debugPrint("deinit \(self)")
    }
}
