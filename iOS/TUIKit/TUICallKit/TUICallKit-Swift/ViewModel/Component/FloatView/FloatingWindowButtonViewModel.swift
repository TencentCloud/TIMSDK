//
//  FloatingWindowButtonViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/6.
//

import Foundation
import TUICallEngine

class FloatingWindowButtonViewModel {
    
    let mediaTypeObserver = Observer()
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)

    init() {
        mediaType.value = TUICallState.instance.mediaType.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        }
    }
}
