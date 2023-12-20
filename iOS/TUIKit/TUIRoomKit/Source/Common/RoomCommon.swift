//
//  RoomCommon.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/26.
//

import Foundation
import AVFoundation
import TUICore

var isRTL: Bool {
    TUIGlobalization.getRTLOption()
}

var isLandscape: Bool {
    guard let orientationIsLandscape = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape as? Bool
    else { return false }
    return orientationIsLandscape
}

class RoomCommon {
    enum AuthorizationDeniedType {
        case microphone
        case camera
    }
    class func checkAuthorMicStatusIsDenied() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
    class func checkAuthorCamaraStatusIsDenied() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    class func micStateActionWithPopCompletion(completion: @escaping (Bool) -> ()) {
        if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                completion(granted)
            }
        } else {
            showAuthorizationAlert(deniedType: .microphone)
        }
    }
    class func cameraStateActionWithPopCompletion(completion: @escaping (Bool) -> () ) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        } else {
            showAuthorizationAlert(deniedType: .camera)
        }
    }
    
    private class func showAuthorizationAlert(deniedType: AuthorizationDeniedType) {
        let laterMessage: String = .permissionLaterText
        let openSettingMessage: String = .permissionEnableText
        let title: String = deniedType == .microphone ? .microphonePermissionTitle : .cameraPermissionTitle
        let message: String = deniedType == .microphone ? .microphonePermissionTipsText : .cameraPermissionTipsText
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        let declineAction = UIAlertAction(title: laterMessage, style: .cancel) { _ in
            
        }
        let sureAction = UIAlertAction(title: openSettingMessage, style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        alertVC.addAction(declineAction)
        alertVC.addAction(sureAction)
        DispatchQueue.main.async {
            let vc = getCurrentWindowViewController()
            vc?.present(alertVC, animated: true)
        }
    }
    
    class func getCurrentWindowViewController() -> UIViewController? {
        var keyWindow: UIWindow?
        for window in UIApplication.shared.windows {
            if window.isMember(of: UIWindow.self), window.isKeyWindow {
                keyWindow = window
                break
            }
        }
        guard let rootController = keyWindow?.rootViewController else {
            return nil
        }
        func findCurrentController(from vc: UIViewController?) -> UIViewController? {
            if let nav = vc as? UINavigationController {
                return findCurrentController(from: nav.topViewController)
            } else if let tabBar = vc as? UITabBarController {
                return findCurrentController(from: tabBar.selectedViewController)
            } else if let presented = vc?.presentedViewController {
                return findCurrentController(from: presented)
            }
            return vc
        }
        let viewController = findCurrentController(from: rootController)
        return viewController
    }
}

private extension String {
    static var microphonePermissionTitle: String {
        localized("TUIRoom.fail.microphone.permission.Title")
    }
    static var microphonePermissionTipsText: String {
        localized("TUIRoom.fail.microphone.permission.Tips")
    }
    static var cameraPermissionTitle: String {
        localized("TUIRoom.fail.camera.permission.Title")
    }
    static var cameraPermissionTipsText: String {
        localized("TUIRoom.fail.camera.permission.Tips")
    }
    static var permissionLaterText: String {
        localized("TUIRoom.fail.permission.Later")
    }
    static var permissionEnableText: String {
        localized("TUIRoom.fail.permission.Enable")
    }
}
