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

class RoomInviteViewModel: NSObject, AVAudioPlayerDelegate {
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
        closeRoomInviteView()
    }
    func agreeAction() {
        stopPlay()
        TUIRoomKit.sharedInstance.addListener(listener: self)
        if messageManager.isEngineLogin {
            if messageManager.hasEnterRoom() {
                messageManager.exitOrDestroyPreviousRoom { [weak self] in
                    guard let self = self else { return }
                    self.enterRoom()
                } onError: { code, message in
                    debugPrint("code:\(code),message:\(message)")
                }
            } else {
                enterRoom()
            }
        } else {
            TUIRoomKit.sharedInstance.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID(), userSig: TUILogin.getUserSig())
        }
    }
    private func enterRoom() {
        let roomInfo = RoomInfo()
        roomInfo.roomId = roomId
        TUIRoomKit.sharedInstance.enterRoom(roomInfo: roomInfo)
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
    
    private func closeRoomInviteView() {
        TUIRoomImAccessService.shared.inviteWindow?.isHidden = true
        TUIRoomImAccessService.shared.inviteWindow = nil
        TUIRoomImAccessService.shared.alreadyShownRoomInviteView = false
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RoomInviteViewModel: TUIRoomKitListener {
    func onLogin(code: Int, message: String) {
        TUIRoomKit.sharedInstance.setSelfInfo(userName: TUILogin.getNickName() ?? "", avatarURL: TUILogin.getFaceUrl() ?? "")
        let roomInfo = RoomInfo()
        roomInfo.roomId = roomId
        TUIRoomKit.sharedInstance.enterRoom(roomInfo: roomInfo)
    }
    func onExitRoom() {
        closeRoomInviteView()
    }
}
