//
//  RoomaInviteViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore
import AVFAudio
import TUIRoomEngine

class InvitedToJoinRoomViewModel: NSObject, AVAudioPlayerDelegate {
    let inviteUserName: String
    let roomId: String
    var avatarUrl: String
    var displayLink: CADisplayLink?
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var startTime: TimeInterval?
    var endTime: TimeInterval?
    var messageManager: RoomMessageManager {
        return RoomMessageManager.shared
    }
    private var roomManager: RoomManager {
        RoomManager.shared
    }
    init(inviteUserName: String, inviteUserAvatarUrl: String, roomId: String) {
        self.inviteUserName = inviteUserName
        self.roomId = roomId
        avatarUrl = inviteUserAvatarUrl
        super.init()
        playAudio(forResource: "phone_ringing", ofType: "mp3")
    }
    
    func startPlay() {
        audioPlayer.play()
    }
    
    func stopPlay() {
        audioPlayer.stop()
    }
    
    func disagreeAction() {
        stopPlay()
        closeInvitedToJoinRoomView()
    }
    
    func agreeAction() {
        stopPlay()
        if EngineManager.createInstance().store.isEnteredRoom {
            roomManager.exitOrDestroyPreviousRoom { [weak self] in
                guard let self = self else { return }
                self.enterRoom()
            } onError: { code, message in
                debugPrint("exitRoom, code:\(code), message:\(message)")
            }
        } else {
            enterRoom()
        }
    }
    
    private func enterRoom() {
        roomManager.enterRoom(roomId: roomId)
        closeInvitedToJoinRoomView()
    }
    
    private func playAudio(forResource: String, ofType: String){
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: ofType) {
            let url = URL(fileURLWithPath: bundlePath)
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            } catch let error {
                debugPrint("AVAudioSession set outputAudioPort error:\(error.localizedDescription)")
            }
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: url)
                audioPlayer.numberOfLoops = -1
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
            } catch let error {
                debugPrint("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    private func closeInvitedToJoinRoomView() {
        TUIRoomImAccessService.shared.inviteWindow?.isHidden = true
        TUIRoomImAccessService.shared.inviteWindow = nil
        TUIRoomImAccessService.shared.isShownInvitedToJoinRoomView = false
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
