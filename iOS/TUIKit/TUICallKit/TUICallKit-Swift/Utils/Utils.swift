//
//  Utils.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import ImSDK_Plus
import TUICore

func DispatchCallKitMainAsyncSafe(closure: @escaping () -> Void) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

let kControlBtnSize = CGSizeMake(100, 92)
let kBtnLargeSize = CGSizeMake(64, 64)
let kBtnSmallSize = CGSizeMake(52, 52)

class TUICallKitCommon {
    
    enum AuthorizationDeniedType {
        case AuthorizationDeniedTypeAudio
        case AuthorizationDeniedTypeVideo
    }
    
    static func createRoomId() -> UInt32 {
       return  1 + arc4random() % (UINT32_MAX / 2  - 1)
    }
    
    static func getTUICallKitBundle() -> Bundle? {
        guard let url: URL = Bundle.main.url(forResource: "TUICallingKitBundle", withExtension: "bundle") else { return nil }
        return Bundle(url: url)
    }
    
    static func getBundleImage(name: String) -> UIImage? {
        return UIImage(named: name, in: self.getTUICallKitBundle(), compatibleWith: nil)
    }
    
    static func getUrlImage(url: String) -> UIImage? {
        guard let url = URL(string: url) else { return nil }
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch _ as NSError {}
        return  UIImage(data: data)
    }
        
    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter({ $0.isKeyWindow }).last
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static func showAuthorizationAlert(deniedType: AuthorizationDeniedType) {
        var title: String
        var message: String
        var laterMessage: String
        var openSettingMessage: String
        
        switch deniedType {
        case .AuthorizationDeniedTypeAudio:
            title = TUICallKitLocalize(key: "TUICallKit.failedtogetmicrophonepermission.Title") ?? ""
            message = TUICallKitLocalize(key: "TUICallKit.failedtogetmicrophonepermission.Tips") ?? ""
            laterMessage = TUICallKitLocalize(key: "TUICallKit.failedtogetmicrophonepermission.Later") ?? ""
            openSettingMessage = TUICallKitLocalize(key: "TUICallKit.failedtogetmicrophonepermission.Enable") ?? ""
        case .AuthorizationDeniedTypeVideo:
            title = TUICallKitLocalize(key: "TUICallKit.failedtogetcamerapermission.Title") ?? ""
            message = TUICallKitLocalize(key: "TUICallKit.failedtogetcamerapermission.Tips") ?? ""
            laterMessage = TUICallKitLocalize(key: "TUICallKit.failedtogetcamerapermission.Later") ?? ""
            openSettingMessage = TUICallKitLocalize(key: "TUICallKit.failedtogetcamerapermission.Enable") ?? ""
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alertController.addAction(UIAlertAction(title: laterMessage, style: .cancel))
        alertController.addAction(UIAlertAction(title: openSettingMessage, style: .default, handler: { action in
            let app = UIApplication.shared
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if app.canOpenURL(url) {
                app.openURL(url)
            }
        }))

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
        }
    }
    
}

