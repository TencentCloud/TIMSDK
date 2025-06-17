//
//  Permission.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import AVFoundation
import RTCRoomEngine

enum AuthorizationDeniedType: Int {
    case audio
    case video
}

class Permission: NSObject {
    static func hasPermission(callMediaType: TUICallMediaType, fail: TUICallFail?) -> Bool  {
        if Permission.checkAuthorizationStatusIsDenied(mediaType: .audio) {
            Permission.showAuthorizationAlert(mediaType: .audio)
            fail?(ERROR_PARAM_INVALID, "call failed, authorization status is denied")
            return false
        }

        if callMediaType == .video && Permission.checkAuthorizationStatusIsDenied(mediaType: .video){
            Permission.showAuthorizationAlert(mediaType: .video)
            fail?(ERROR_PARAM_INVALID, "call failed, authorization status is denied")
            return false
        }
        
        return true
    }
    
    static func showAuthorizationAlert(mediaType: TUICallMediaType) {
        let statusVideo: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        var deniedType: AuthorizationDeniedType = AuthorizationDeniedType.audio
        
        if mediaType == .video && statusVideo == .denied {
            deniedType = .video
        }
        
        Permission.showAuthorizationAlert(deniedType: deniedType) {
            CallManager.shared.hangup() { } fail: { code, message in }
        } cancelHandler: {
            CallManager.shared.hangup() { } fail: { code, message in }
        }
    }

    static func checkAuthorizationStatusIsDenied(mediaType: TUICallMediaType) -> Bool {
        let statusAudio: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let statusVideo: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        if mediaType == TUICallMediaType.video && statusVideo == .denied {
            return true
        }
        
        if mediaType == TUICallMediaType.audio && statusAudio == .denied {
            return true
        }
        
        return false
    }

    static func showAuthorizationAlert(deniedType: AuthorizationDeniedType,
                                              openSettingHandler: @escaping () -> Void,
                                              cancelHandler: @escaping () -> Void) {
        var title: String
        var message: String
        var laterMessage: String
        var openSettingMessage: String
        
        switch deniedType {
        case .audio:
            title = TUICallKitLocalize(key: "TUICallKit.FailedToGetMicrophonePermission.Title") ?? ""
            message = TUICallKitLocalize(key: "TUICallKit.FailedToGetMicrophonePermission.Tips") ?? ""
            laterMessage = TUICallKitLocalize(key: "TUICallKit.FailedToGetMicrophonePermission.Later") ?? ""
            openSettingMessage = TUICallKitLocalize(key: "TUICallKit.FailedToGetMicrophonePermission.Enable") ?? ""
        case .video:
            title = TUICallKitLocalize(key: "TUICallKit.FailedToGetCameraPermission.Title") ?? ""
            message = TUICallKitLocalize(key: "TUICallKit.FailedToGetCameraPermission.Tips") ?? ""
            laterMessage = TUICallKitLocalize(key: "TUICallKit.FailedToGetCameraPermission.Later") ?? ""
            openSettingMessage = TUICallKitLocalize(key: "TUICallKit.FailedToGetCameraPermission.Enable") ?? ""
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert )
        
        alertController.addAction(UIAlertAction(title: laterMessage, style: .cancel, handler:  { action in
            cancelHandler()
        }))
        
        alertController.addAction(UIAlertAction(title: openSettingMessage, style: .default, handler: { action in
            openSettingHandler()
            let app = UIApplication.shared
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if app.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    app.open(url)
                } else {
                    app.openURL(url)
                }
            }
        }))
        
        DispatchQueue.main.async {
            UIWindow.getKeyWindow()?.rootViewController?.present(alertController, animated: true)
        }
    }
}
