//
//  CallWaitingHintViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/9.
//

import Foundation
import TUICallEngine

class CallWaitingHintViewModel {
    
    let callStatusObserver = Observer()
    
    let selfCallStatus: Observable<TUICallStatus> = Observable(.none)
   
    init() {
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(callStatusObserver)
    }
    
    func registerObserve() {

        TUICallState.instance.selfUser.value.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
        })
    }
}
