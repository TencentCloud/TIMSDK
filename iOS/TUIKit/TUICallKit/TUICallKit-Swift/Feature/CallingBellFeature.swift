//
//  CallingBellFeature.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import AVFAudio
import TUICallEngine

#if USE_TRTC
import TXLiteAVSDK_TRTC
#else
import TXLiteAVSDK_Professional
#endif

let CALLKIT_AUDIO_DIAL_ID: Int32 = 48

class CallingBellFeature: NSObject, AVAudioPlayerDelegate {
    
    enum CallingBellType {
        case CallingBellTypeHangup
        case CallingBellTypeCalled
        case CallingBellTypeDial
    }
    
    static let instance = CallingBellFeature()
    var player: AVAudioPlayer?
    var loop: Bool = true
    
    func startPlayMusic(type: CallingBellType) -> Bool {
        guard let bundle = TUICallKitCommon.getTUICallKitBundle() else { return false }
        switch type {
        case .CallingBellTypeHangup:
            let path = bundle.bundlePath + "/AudioFile" + "/phone_hangup.mp3"
            let url = URL(fileURLWithPath: path)
            return startPlayMusicBySystemPlayer(url: url, loop: false)
        case .CallingBellTypeCalled:
            if TUICallState.instance.enableMuteMode {
                return false
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
            return true
        }
    }
    
    func stopPlayMusic() {
        if TUICallState.instance.selfUser.value.callRole.value == .call {
            stopPlayMusicByTRTCPlayer(id: CALLKIT_AUDIO_DIAL_ID)
            return
        }
        stopPlayMusicBySystemPlayer()
    }

    // MARK: TRTC Audio Player
    private func startPlayMusicByTRTCPlayer(path: String, id: Int32) {
        CallEngineManager.instance.setAudioPlaybackDevice(device: TUICallState.instance.mediaType.value == .audio ? .earpiece : .speakerphone)
        let param = TXAudioMusicParam()
        param.id = id
        param.isShortFile = true
        param.path = path
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().startPlayMusic(param,
                                                                                                     onStart: nil,
                                                                                                     onProgress: nil)
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().setMusicPlayoutVolume(id, volume: 100)
    }
    
    private func stopPlayMusicByTRTCPlayer(id: Int32) {
        TUICallEngine.createInstance().getTRTCCloudInstance().getAudioEffectManager().stopPlayMusic(id)
    }

    // MARK: System AVAudio Player
    private func startPlayMusicBySystemPlayer(url: URL, loop: Bool = true) -> Bool {
        self.loop = loop
        
        if player != nil {
            stopPlayMusicBySystemPlayer()
        }
        
        do {
            try player = AVAudioPlayer(contentsOf: url)
        } catch let error as NSError {
            print("err: \(error.localizedDescription)")
            return false
        }
                
        guard let prepare = player?.prepareToPlay() else { return false }
        if !prepare {
            return false
        }
        
        setAudioSessionPlayback()
        
        player?.delegate = self
        guard let res = player?.play() else { return false }

        return res
    }
        
    private func stopPlayMusicBySystemPlayer() {
        if player == nil {
            return
        }
        player?.stop()
        player = nil
    }
    
    // MARK: AVAudioPlayerDelegate
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loop {
            player.play()
        } else {
            stopPlayMusicBySystemPlayer()
        }
    }
    
    internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            stopPlayMusicBySystemPlayer()
        }
    }
    
    private func setAudioSessionPlayback() {
        let audioSession = AVAudioSession()
        try? audioSession.setCategory(.soloAmbient)
        try? audioSession.setActive(true)
    }
}
