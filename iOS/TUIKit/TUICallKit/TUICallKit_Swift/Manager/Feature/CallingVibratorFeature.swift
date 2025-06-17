//
//  CallingVibrator.swift
//  TUICallKit-Swift
//
//  Created by iveshe on 2024/12/31.
//

import AudioToolbox
import RTCRoomEngine
import RTCCommon

class CallingVibratorFeature: NSObject {
    private static var isVibrating = false;
    let selfUserCallStatusObserver = Observer()
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    deinit {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfUserCallStatusObserver)
    }
    
    func registerObserveState() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfUserCallStatusObserver, closure: { newValue, _ in
            let callStatus = CallManager.shared.userState.selfUser.callStatus.value
            let callRole = CallManager.shared.userState.selfUser.callRole.value
            
            if callStatus == TUICallStatus.waiting && callRole == TUICallRole.called {
                CallingVibratorFeature.startVibration()
            } else {
                CallingVibratorFeature.stopVibration()
            }
        })
    }

    private static func startVibration() {
        isVibrating = true
        vibrate()
    }
    
    private static func vibrate() {
        guard isVibrating else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            vibrate()
        }
    }

    private static func stopVibration() {
        isVibrating = false;
    }
}
