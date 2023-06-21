//
//  TimerViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/24.
//

import Foundation
import TUICallEngine

class TimerViewModel {

    let timeCountObserver = Observer()
    let mediaTypeObserver = Observer()

    let timeCount: Observable<Int> = Observable(0)
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)

    init() {
        timeCount.value = TUICallState.instance.timeCount.value
        mediaType.value = TUICallState.instance.mediaType.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.timeCount.removeObserver(timeCountObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.timeCount.addObserver(timeCountObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.timeCount.value = newValue

        })
        
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        }
    }
    
    func getCallTimeString() -> String {
        return GCDTimer.secondToHMSString(second: timeCount.value)
    }
}
