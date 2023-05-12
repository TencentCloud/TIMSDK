//
//  CallKitController.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import AVFAudio

class CallingBellFeature {
    
    enum CallingBellType {
        case CallingBellTypeHangup
        case CallingBellTypeCalled
        case CallingBellTypeDial
    }
    
    static let instance = CallingBellFeature()
    
    func playCallingBellWithFilePath(filePath: String) -> Bool {
        let url = URL(fileURLWithPath: filePath)
        return CallingBellPlayer.instance.playAudio(url: url)
    }
    
    func playCallingBell(type: CallingBellType) -> Bool {
        guard let bundle = TUICallKitCommon.getTUICallKitBundle() else { return false }
        switch type {
        case .CallingBellTypeHangup:
            let path = bundle.bundlePath + "/AudioFile" + "/phone_hangup.mp3"
            let url = URL(fileURLWithPath: path)
            return CallingBellPlayer.instance.playAudio(url: url, loop: false)
        case .CallingBellTypeCalled:
            if TUICallState.instance.enableMuteMode {
                return false
            }
            var path = bundle.bundlePath + "/AudioFile" + "/phone_ringing.mp3"
            
            
            if let value = UserDefaults.standard.object(forKey: TUI_CALLING_BELL_KEY) as? String {
                path = value
            }
            
            let url = URL(fileURLWithPath: path)
            return CallingBellPlayer.instance.playAudio(url: url)
        case .CallingBellTypeDial:
            let path = bundle.bundlePath + "/AudioFile" + "/phone_dialing.m4a"
            let url = URL(fileURLWithPath: path)
            return CallingBellPlayer.instance.playAudio(url: url)
        }
    }
    
    func stopAudio() {
        CallingBellPlayer.instance.stopPlay()
    }
}

class CallingBellPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let instance = CallingBellPlayer()
    
    var player: AVAudioPlayer?
    var loop: Bool = true
        
    func playAudio(url: URL, loop: Bool = true) -> Bool {
        self.loop = loop
        
        if player != nil {
            stopPlay()
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
        
    func stopPlay() {
        if player == nil {
            return
        }
        player?.stop()
        player = nil
    }
    
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if loop {
            player.play()
        } else {
            stopPlay()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if error != nil {
            stopPlay()
        }
    }
    
    func setAudioSessionPlayback() {
        let audioSession = AVAudioSession()
        try? audioSession.setCategory(.soloAmbient)
        try? audioSession.setActive(true)
    }
}
