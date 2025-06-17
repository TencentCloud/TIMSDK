//
//  CallingBellFeature.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import AVFAudio
import RTCRoomEngine
import RTCCommon

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

let CALLKIT_AUDIO_DIAL_ID: Int32 = 48

class CallingBellFeature: NSObject, AVAudioPlayerDelegate {
    
    enum CallingBellType {
        case CallingBellTypeHangup
        case CallingBellTypeCalled
        case CallingBellTypeDial
    }
    
    var player: AVAudioPlayer?
    var loop: Bool = true
    private var needPlayRingtone: Bool = false
    let selfUserCallStatusObserver = Observer()
    
    override init() {
        super.init()
        registerNotifications()
        registerObserveState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfUserCallStatusObserver)
    }
    
    func registerObserveState() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfUserCallStatusObserver, closure: { newValue, _ in
            let callStatus = CallManager.shared.userState.selfUser.callStatus.value
            let callRole = CallManager.shared.userState.selfUser.callRole.value
            
            if callStatus == TUICallStatus.waiting {
                if callRole == TUICallRole.called {
                    self.startMusicBasedOnAppState(type: .CallingBellTypeCalled)
                } else if callRole == TUICallRole.call {
                    self.startPlayMusic(type: .CallingBellTypeDial)
                }
            } else {
                self.stopPlayMusic()
            }
        })
    }
    
    func startMusicBasedOnAppState(type: CallingBellType) {
        if UIApplication.shared.applicationState != .background {
            self.setAudioSessionWith(category: .soloAmbient)
            self.startPlayMusic(type: type)
        } else {
            self.needPlayRingtone = true;
        }
    }
    
    func registerNotifications() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
                                                   name: UIScene.didActivateNotification,
                                                   object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
                                                   name: UIApplication.didBecomeActiveNotification,
                                                   object: nil)
        }
    }
    
    @objc func appDidBecomeActive() {
        if needPlayRingtone {
            let _ = startPlayMusic(type: .CallingBellTypeCalled)
            needPlayRingtone = false;
        }
    }
    
    func startPlayMusic(type: CallingBellType) {
        guard let bundle = CallKitBundle.getTUICallKitBundle() else { return }
        switch type {
        case .CallingBellTypeHangup:
            let path = bundle.bundlePath + "/AudioFile" + "/phone_hangup.mp3"
            let url = URL(fileURLWithPath: path)
            return startPlayMusicBySystemPlayer(url: url, loop: false)
        case .CallingBellTypeCalled:
            if CallManager.shared.globalState.enableMuteMode {
                return
            }
            var path = bundle.bundlePath + "/AudioFile" + "/phone_ringing.mp3"
            
            
            if let value = UserDefaults.standard.object(forKey: TUI_CALLING_BELL_KEY) as? String {
                path = value
            }
            
            let url = URL(fileURLWithPath: path)
            return startPlayMusicBySystemPlayer(url: url)
        case .CallingBellTypeDial:
            let path = bundle.bundlePath + "/AudioFile" + "/phone_dialing.m4a"
            startPlayMusicByTRTCPlayer(path: path, id: CALLKIT_AUDIO_DIAL_ID)
            return
        }
    }
    
    func stopPlayMusic() {
        setAudioSessionWith(category: .playAndRecord)
        
        if CallManager.shared.userState.selfUser.callRole.value == .call {
            stopPlayMusicByTRTCPlayer(id: CALLKIT_AUDIO_DIAL_ID)
            return
        }
        stopPlayMusicBySystemPlayer()
        needPlayRingtone = false;
    }
    
    // MARK: TRTC Audio Player
    private func startPlayMusicByTRTCPlayer(path: String, id: Int32) {
        let audioDevice: TUIAudioPlaybackDevice = CallManager.shared.callState.mediaType.value == .audio ? .earpiece : .speakerphone
        CallManager.shared.setAudioPlaybackDevice(device: audioDevice)
        
        let param = TXAudioMusicParam()
        param.id = id
        param.isShortFile = true
        param.path = path
        
        let audioEffectManager = TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager()
        audioEffectManager.startPlayMusic(param, onStart: nil, onProgress: nil)
        audioEffectManager.setMusicPlayoutVolume(id, volume: 100)
    }
    
    private func stopPlayMusicByTRTCPlayer(id: Int32) {
        let audioEffectManager = TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager()
        audioEffectManager.stopPlayMusic(id)
    }
    
    // MARK: System AVAudio Player
    private func startPlayMusicBySystemPlayer(url: URL, loop: Bool = true) {
        self.loop = loop
        
        if player != nil {
            stopPlayMusicBySystemPlayer()
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        guard let prepare = player?.prepareToPlay(), prepare else {
            return
        }
        
        player?.delegate = self
        player?.play()
    }
    
    private func stopPlayMusicBySystemPlayer() {
        player?.stop()
        player = nil
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loop {
            player.play()
        } else {
            stopPlayMusicBySystemPlayer()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            stopPlayMusicBySystemPlayer()
        }
    }
    
    private func setAudioSessionWith(category: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(category, options: [.allowBluetooth, .allowBluetoothA2DP, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
}
