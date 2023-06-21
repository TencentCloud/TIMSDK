//
//  BroadcastLauncher.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

import ReplayKit
import UIKit

@available(iOS 12.0, *)
class BroadcastLauncher: NSObject {
    var systemExtensionPicker = RPSystemBroadcastPickerView()
    var prevLaunchEventTime: CFTimeInterval = 0
    
    static let sharedInstance = BroadcastLauncher()
    
    override private init() {
        super.init()
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        picker.showsMicrophoneButton = false
        picker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        systemExtensionPicker = picker
        
        if let pluginPath = Bundle.main.builtInPlugInsPath,
           let contents = try? FileManager.default.contentsOfDirectory(atPath: pluginPath) {
            for content in contents where content.hasSuffix(".appex") {
                guard let bundle = Bundle(path: URL(fileURLWithPath: pluginPath).appendingPathComponent(content).path),
                      let identifier: String = (bundle.infoDictionary?["NSExtension"] as? [String: Any])? ["NSExtensionPointIdentifier"] as? String
                else {
                    continue
                }
                if identifier == "com.apple.broadcast-services-upload" {
                    picker.preferredExtension = bundle.bundleIdentifier
                    break
                }
            }
        }
    }
    
    static func launch() {
        BroadcastLauncher.sharedInstance.launch()
    }
    
    func launch() {
        let now = CFAbsoluteTimeGetCurrent()
        if now - prevLaunchEventTime < 1.0 {
            return
        }
        prevLaunchEventTime = now
        
        for view in systemExtensionPicker.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .allTouchEvents)
                break
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
