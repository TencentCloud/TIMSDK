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
    func updateStackView(item: ButtonItemData)
#if RTCube_APPSTORE
    func showReportView()
#endif
}

class TopViewModel: NSObject {
    private var topMenuTimer: DispatchSourceTimer?
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
    
    override init() {
        super.init()
        createBottomData()
        initialStatus()
        subscribeUIEvent()
    }
    
    private func createBottomData() {
        let micItem = ButtonItemData()
        micItem.normalIcon = "room_earpiece"
        micItem.selectedIcon = "room_speakerphone"
        micItem.backgroundColor = UIColor(0xA3AEC7)
        micItem.resourceBundle = tuiRoomKitBundle()
        micItem.buttonType = .switchMicItemType
        micItem.isSelect = engineManager.store.audioSetting.isSoundOnSpeaker
        micItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.switchMicItemAction(sender: button)
        }
        viewItems.append(micItem)
        let cameraItem = ButtonItemData()
        cameraItem.normalIcon = "room_switch_camera"
        cameraItem.backgroundColor = UIColor(0xA3AEC7)
        cameraItem.resourceBundle = tuiRoomKitBundle()
        cameraItem.buttonType = .switchCamaraItemType
        cameraItem.isHidden = !currentUser.hasVideoStream
        cameraItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.switchCameraItemAction(sender: button)
        }
        viewItems.append(cameraItem)
#if RTCube_APPSTORE
        injectReport()
#endif
    }
    
    private func initialStatus() {
        if engineManager.store.audioSetting.isSoundOnSpeaker {
            engineManager.setAudioRoute(route: .modeSpeakerphone)
        } else {
            engineManager.setAudioRoute(route: .modeEarpiece)
        }
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasVideoStream, responder: self)
    }
    
    private func unsubscribeUIEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasVideoStream, responder: self)
    }
    
    private func switchMicItemAction(sender: UIButton) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            engineManager.setAudioRoute(route: .modeSpeakerphone)
        } else {
            engineManager.setAudioRoute(route: .modeEarpiece)
        }
    }
    
    private func switchCameraItemAction(sender: UIButton) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        engineManager.switchCamera()
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
    
    func dropDownAction(sender: UIView) {
        RoomRouter.shared.presentPopUpViewController(viewType: .roomInfoViewType, height: 258)
    }
    
    func exitAction(sender: UIView) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowExitRoomView, param: [:])
    }
    
    func updateTimerLabelText() {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        var totalSeconds: UInt = UInt(labs(timeStamp - store.timeStampOnEnterRoom))
        updateTimer(totalSeconds: totalSeconds)
        topMenuTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        topMenuTimer?.schedule(deadline: .now(), repeating: .seconds(1))
        topMenuTimer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            totalSeconds += 1
            self.updateTimer(totalSeconds: totalSeconds)
        }
        topMenuTimer?.resume()
    }
    
    deinit {
        unsubscribeUIEvent()
        topMenuTimer?.cancel()
        topMenuTimer = nil
        debugPrint("deinit \(self)")
    }
}

extension TopViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_CurrentUserHasVideoStream:
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard let item = viewItems.first(where: { $0.buttonType == .switchCamaraItemType }) else { return }
            item.isHidden = !hasVideo
            viewResponder?.updateStackView(item: item)
        default: break
        }
    }
}

#if RTCube_APPSTORE
extension TopViewModel {
    private func injectReport() {
        if currentUser.userId == roomInfo.roomId {
           return
        }
        let reportItem = ButtonItemData()
        reportItem.normalIcon = "room_report"
        reportItem.backgroundColor = UIColor(0xA3AEC7)
        reportItem.resourceBundle = tuiRoomKitBundle()
        reportItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.reportItemAction(sender: button)
        }
        viewItems.append(reportItem)
    }
    
    private func reportItemAction(sender: UIButton) {
        viewResponder?.showReportView()
    }
}
#endif

