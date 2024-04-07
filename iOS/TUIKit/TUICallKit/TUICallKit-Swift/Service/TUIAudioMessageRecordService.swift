//
//  TUIAudioMessageRecordService.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/8/16.
//

import Foundation
import AVFAudio
import TUICore
import TUICallEngine

#if USE_TRTC
import TXLiteAVSDK_TRTC
#else
import TXLiteAVSDK_Professional
#endif

class TUIAudioRecordInfo {
    var path: String = ""
    var sdkAppId: Int = 0
    var signature: String = ""
}

class TUIAudioMessageRecordService: NSObject, TUIServiceProtocol, TUINotificationProtocol, TRTCCloudDelegate,  TUICallObserver {
    
    static let instance = TUIAudioMessageRecordService()
    
    var audioRecordInfo: TUIAudioRecordInfo?
    var category: AVAudioSession.Category?
    var categoryOptions: AVAudioSession.CategoryOptions?
    
    var callback: TUICallServiceResultCallback?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccessNotification),
                                               name: NSNotification.Name.TUILoginSuccess, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func loginSuccessNotification() {
        TUICallEngine.createInstance().addObserver(self)
    }
}

// MARK: TUIServiceProtocol
extension TUIAudioMessageRecordService {
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        return nil
    }
    
    func onCall(_ method: String, param: [AnyHashable : Any]?, resultCallback: @escaping TUICallServiceResultCallback) -> Any? {
        callback = resultCallback
        
        if method == TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod {
            guard let param = param else {
                notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                              errorCode: Int(TUICore_RecordAudioMessageNotifyError_InvalidParam), path: "")
                return nil
            }
            
            if TUICallState.instance.selfUser.value.callStatus.value != TUICallStatus.none {
                notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                              errorCode: Int(TUICore_RecordAudioMessageNotifyError_StatusInCall), path: "")
                return nil
            }
            
            if audioRecordInfo != nil {
                notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                              errorCode: Int(TUICore_RecordAudioMessageNotifyError_StatusIsAudioRecording), path: "")
                return nil
            }
            
            requestRecordAuthorization { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    if !self.requestAudioFocus() {
                        self.notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                                           errorCode: Int(TUICore_RecordAudioMessageNotifyError_RequestAudioFocusFailed), path: "")
                    } else {
                        self.audioRecordInfo = TUIAudioRecordInfo()
                        let pathKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey
                        self.audioRecordInfo?.path = param[pathKey] as? String ?? ""
                        let sdkAppId = param[TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey] as? NSNumber
                        if let sdkAppId = sdkAppId {
                            self.audioRecordInfo?.sdkAppId = sdkAppId.intValue
                        }
                        let signatureKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SignatureKey
                        self.audioRecordInfo?.signature = param[signatureKey] as? String ?? ""
                        
                        TRTCCloud.sharedInstance().delegate = self
                        let audioVolumeEvaluateParams = TRTCAudioVolumeEvaluateParams()
                        audioVolumeEvaluateParams.interval = 500
                        TRTCCloud.sharedInstance().enableAudioVolumeEvaluation(true, with: audioVolumeEvaluateParams)
                        self.startRecordAudioMessage()
                    }
                } else {
                    self.notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                                       errorCode: Int(TUICore_RecordAudioMessageNotifyError_MicPermissionRefused), path: "")
                }
            }
            
            return nil
            
        } else if method == TUICore_TUIAudioMessageRecordService_StopRecordAudioMessageMethod {
            stopRecordAudioMessage()
        }
        
        return nil
    }
    
    func requestRecordAuthorization(response: @escaping (_ granted: Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        let permission = session.recordPermission
        
        if permission == .undetermined {
            session.requestRecordPermission(response)
        } else if permission == .granted {
            response(true)
        } else if permission == .denied {
            response(false)
        }
    }
    
    func startRecordAudioMessage() {
        guard let audioRecordInfo = audioRecordInfo else { return }
        
        let sdkAppIdKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_SdkappidKey
        let pathKey = TUICore_TUIAudioMessageRecordService_StartRecordAudioMessageMethod_PathKey
        
        let jsonParams: [String: Any] = ["api": "startRecordAudioMessage",
                                         "params": ["key": audioRecordInfo.signature,
                                                    sdkAppIdKey: audioRecordInfo.sdkAppId,
                                                    pathKey: audioRecordInfo.path,] as [String : Any],]
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else { return }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else { return }
        
        TRTCCloud.sharedInstance().callExperimentalAPI(paramsString)
    }
    
    func stopRecordAudioMessage() {
        guard let _ = audioRecordInfo else { return }
        
        let jsonParams: [String: Any] = ["api": "stopRecordAudioMessage",
                                         "params": [:] as  [String : Any],]
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else { return }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else { return }
        TRTCCloud.sharedInstance().callExperimentalAPI(paramsString)
        TRTCCloud.sharedInstance().enableAudioVolumeEvaluation(false, with: TRTCAudioVolumeEvaluateParams())
        TRTCCloud.sharedInstance().stopLocalAudio()
        
        audioRecordInfo = nil
        
        let _  = abandonAudioFocus()
    }
}

// MARK: TUICallObserver
extension TUIAudioMessageRecordService {
    func onCallReceived(callerId: String, calleeIdList: [String], groupId: String?, callMediaType: TUICallMediaType, userData: String?) {
        stopRecordAudioMessage()
    }
}

// MARK: TRTCCloudDelegate
extension TUIAudioMessageRecordService {
    func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        if errCode.rawValue == TUICore_RecordAudioMessageNotifyError_MicStartFail ||
            errCode.rawValue == TUICore_RecordAudioMessageNotifyError_MicNotAuthorized ||
            errCode.rawValue == TUICore_RecordAudioMessageNotifyError_MicSetParamFail ||
            errCode.rawValue == TUICore_RecordAudioMessageNotifyError_MicOccupy {
            notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                          errorCode: Int(errCode.rawValue) , path: "")
        }
    }
    
    func onLocalRecordBegin(_ errCode: Int, storagePath: String) {
        if errCode == TUICore_RecordAudioMessageNotifyError_None {
            TRTCCloud.sharedInstance().startLocalAudio(TRTCAudioQuality.speech)
        }
        let tempCode = convertErrorCode("onLocalRecordBegin", errorCode: errCode)
        notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StartRecordAudioMessageSubKey,
                                      errorCode: Int(tempCode), path: storagePath)
    }
    
    func onLocalRecordComplete(_ errCode: Int, storagePath: String) {
        let tempCode = convertErrorCode("onLocalRecordComplete", errorCode: errCode)
        notifyAudioMessageRecordEvent(method: TUICore_RecordAudioMessageNotify_StopRecordAudioMessageSubKey,
                                      errorCode: Int(tempCode), path: storagePath)
    }
    
    func onUserVoiceVolume(_ userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
        for volumeInfo in userVolumes {
            if volumeInfo.userId == nil || volumeInfo.userId?.isEmpty == true {
                let param = [TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey_VolumeKey: volumeInfo.volume,]
                TUICore.notifyEvent(TUICore_RecordAudioMessageNotify,
                                    subKey: TUICore_RecordAudioMessageNotify_RecordAudioVoiceVolumeSubKey,
                                    object: nil, param: param)
                break
            }
        }
    }
}

// MARK: Private
extension TUIAudioMessageRecordService {
    
    func requestAudioFocus() -> Bool {
        let session = AVAudioSession.sharedInstance()
        category = session.category
        categoryOptions = session.categoryOptions
        do {
            try session.setCategory(.playAndRecord, options: .allowBluetooth)
            try session.setActive(true)
            return true
        } catch {
            return false
        }
    }
    
    func abandonAudioFocus() -> Bool {
        guard let category = category else { return false }
        guard let categoryOptions = categoryOptions else { return false }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(category, options: categoryOptions)
            try session.setActive(false, options: .notifyOthersOnDeactivation)
            return true
        } catch {
            return false
        }
    }
    
    func notifyAudioMessageRecordEvent(method: String, errorCode: Int, path: String) {
        let params: [String: Any] = ["method": method,
                                     "errorCode": errorCode,
                                     "path": path,]
        
        guard let callback = callback else { return }
        callback(errorCode, "", params)
    }
    
    func convertErrorCode(_ method: String?, errorCode: Int) -> Int32 {
        var targetCode: Int32
        switch errorCode {
        case -1:
            if let method = method, method == "onLocalRecordBegin" {
                targetCode = TUICore_RecordAudioMessageNotifyError_RecordInitFailed
            } else {
                targetCode = TUICore_RecordAudioMessageNotifyError_RecordFailed
            }
        case -2:
            targetCode = TUICore_RecordAudioMessageNotifyError_PathFormatNotSupport
        case -3:
            targetCode = TUICore_RecordAudioMessageNotifyError_NoMessageToRecord
        case -4:
            targetCode = TUICore_RecordAudioMessageNotifyError_SignatureError
        case -5:
            targetCode = TUICore_RecordAudioMessageNotifyError_SignatureExpired
        default:
            targetCode = TUICore_RecordAudioMessageNotifyError_None
        }
        return targetCode
    }
}
