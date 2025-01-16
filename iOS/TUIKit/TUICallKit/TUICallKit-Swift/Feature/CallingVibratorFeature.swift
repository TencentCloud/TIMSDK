//
//  CallingVibrator.swift
//  TUICallKit-Swift
//
//  Created by iveshe on 2024/12/31.
//

import AudioToolbox
import TUICallEngine

class CallingVibratorFeature: NSObject {
    private static var isVibrating = false;
    let selfUserCallStatusObserver = Observer()
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfUserCallStatusObserver)
    }
    
    func registerObserveState() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfUserCallStatusObserver, closure: { newValue, _ in
            let callStatus = TUICallState.instance.selfUser.value.callStatus.value
            let callRole = TUICallState.instance.selfUser.value.callRole.value
            
            if callStatus == TUICallStatus.waiting && callRole == TUICallRole.called {
                CallingVibratorFeature.startVibration()
            } else {
                CallingVibratorFeature.stopVibration()
            }
        })
    }

    static func startVibration() {
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

    static func stopVibration() {
        isVibrating = false;
    }
}
