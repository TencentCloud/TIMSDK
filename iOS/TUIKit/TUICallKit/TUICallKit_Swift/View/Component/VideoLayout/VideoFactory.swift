//
//  VideoFactory.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import RTCCommon

class UserVideoEntity {
    var user: User
    var videoView: VideoView
    
    init(user: User, videoView: VideoView) {
        self.user = user
        self.videoView = videoView
    }
}

class VideoFactory {
    static let shared = VideoFactory()
    private var videoEntityMap : [String: UserVideoEntity] = [:]
    private let callStatusObserver = Observer()
            
    func createVideoView(user: User, isShowFloatWindow: Bool = false) -> VideoView? {
        if user.id.value.isEmpty {
            Logger.error("VideoFactory - createVideoView. userId is empty.")
            return nil
        }
        
        if let videoView = getVideoView(user: user) {
            Logger.info("VideoFactory - createVideoView. Get an existing Videoview. userId:\(user.id.value), videoView:\(videoView)")
            videoView.setIsShowFloatWindow(isShowFloatWindow: isShowFloatWindow)
            return videoView
        }
        
        let videoView = VideoView(user: user, isShowFloatWindow: isShowFloatWindow)
        let videoEntity = UserVideoEntity(user: user, videoView: videoView)
        videoEntityMap[user.id.value] = videoEntity
        Logger.info("VideoFactory - createVideoView. Create a new Videoview. userId:\(user.id.value), videoView:\(videoView)")
        return videoView
    }
    
    private func getVideoView(user: User) -> VideoView? {
        guard let videoEntity = videoEntityMap[user.id.value] else {
            return nil
        }
        return videoEntity.videoView
    }
    
    func removeVideoView(user: User) {
        Logger.info("VideoFactory - removeVideoView. userId:\(user.id.value)")
        videoEntityMap.removeValue(forKey: user.id.value)
    }
    
    func removeAllVideoView() {
        Logger.info("VideoFactory - removeAllVideoView.")
        videoEntityMap.removeAll()
    }
}
