//
//  CallKitBundle.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

class CallKitBundle: NSObject {
    static func getTUICallKitBundle() -> Bundle? {
        guard let url: URL = Bundle.main.url(forResource: "TUICallKitBundle", withExtension: "bundle") else { return nil }
        return Bundle(url: url)
    }
    
    static func getBundleImage(name: String) -> UIImage? {
        return UIImage(named: name, in: getTUICallKitBundle(), compatibleWith: nil)
    }
    
}
