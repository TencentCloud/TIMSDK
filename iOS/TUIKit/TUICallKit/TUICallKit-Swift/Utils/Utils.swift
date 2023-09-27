//
//  Utils.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation

func DispatchCallKitMainAsyncSafe(closure: @escaping () -> Void) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}
