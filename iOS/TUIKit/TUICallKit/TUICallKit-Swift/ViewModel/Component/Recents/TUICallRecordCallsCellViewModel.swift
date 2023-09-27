//
//  TUICallRecordCallsCellViewModel.swift
//  
//
//  Created by vincepzhang on 2023/8/28.
//

import Foundation
import UIKit
import TUICallEngine
import ImSDK_Plus
import TUICore

class TUICallRecordCallsCellViewModel {
    
    var avatarImage: UIImage = UIImage()
    var faceURL: Observable<String> = Observable("")
    
    var titleLabelStr: Observable<String> = Observable("")
    var mediaTypeImageStr: String = ""
    var resultLabelStr: String = ""
    var timeLabelStr: String = ""
    
    var callRecord: TUICallRecords
    
    init(_ record: TUICallRecords) {
        callRecord = record
        
        configAvatarImage(callRecord)
        configResult(callRecord.result)
        configMediaTypeImageName(callRecord.mediaType)
        configTitle(callRecord)
        configTime(callRecord)
    }
    
    private func configAvatarImage(_ callRecord: TUICallRecords) {
        if callRecord.scene == .group {
            
            var inviteList = callRecord.inviteList
            inviteList.insert(callRecord.inviter, at: 0)
            guard let inviteList = inviteList as? [String] else { return }
            configGroupAvatarImage(inviteList)
            
        } else if callRecord.scene == .single {
            configSingleAvatarImage(callRecord)
        } else {
            avatarImage = TUICoreDefineConvert.getDefaultGroupAvatarImage()
        }
    }
    
    private func configGroupAvatarImage(_ inviteList: [String]) {
        if inviteList.isEmpty {
            avatarImage = TUICoreDefineConvert.getDefaultGroupAvatarImage()
            return
        }
        
        let inviteStr = inviteList.joined(separator: "#")
        
        getCacheAvatarForInviteStr(inviteStr) { [weak self] avatar in
            guard let self = self else { return }
            if let avatar = avatar {
                self.avatarImage = avatar
            } else {
                V2TIMManager.sharedInstance()?.getUsersInfo(inviteList, succ: { infoList in
                    var avatarsList = [String]()
                    
                    infoList?.forEach { userFullInfo in
                        if let faceURL = userFullInfo.faceURL, !faceURL.isEmpty {
                            avatarsList.append(faceURL)
                        } else {
                            avatarsList.append("http://placeholder")
                        }
                    }
                    TUIGroupAvatar.createGroupAvatar(avatarsList, finished: { [weak self] image in
                        guard let self = self else { return }
                        self.avatarImage = image
                        self.cacheGroupCallAvatar(image, inviteStr: inviteStr)
                    })
                }, fail: nil)
            }
        }
    }
    
    private func configSingleAvatarImage(_ callRecord: TUICallRecords) {
        avatarImage = TUICoreDefineConvert.getDefaultAvatarImage()
        var useId = callRecord.inviter
        
        if callRecord.role == .call {
            guard let firstInvite = callRecord.inviteList.first as? String else { return }
            useId = firstInvite
        }
        
        if !useId.isEmpty {
            V2TIMManager.sharedInstance()?.getUsersInfo([useId], succ: { [weak self] infoList in
                guard let self = self else { return }
                if let userFullInfo = infoList?.first {
                    if let faceURL = userFullInfo.faceURL, !faceURL.isEmpty, faceURL.hasPrefix("http") {
                        self.faceURL.value = faceURL
                    }
                }
            }, fail: nil)
        }
    }
    
    private func configResult(_ callResultType: TUICallResultType) {
        switch callResultType {
        case .missed:
            resultLabelStr = "Missed"
        case .incoming:
            resultLabelStr = "Incoming"
        case .outgoing:
            resultLabelStr = "Outgoing"
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    private func configMediaTypeImageName(_ callMediaType: TUICallMediaType) {
        if callMediaType == .audio {
            mediaTypeImageStr = "ic_recents_audio"
        } else if callMediaType == .video {
            mediaTypeImageStr = "ic_recents_video"
        }
    }
    
    func configTitle(_ callRecord: TUICallRecords) {
        titleLabelStr.value = ""
        var allUsers: [String] = []
        
        switch callRecord.scene {
        case .single:
            if callRecord.role == .call {
                guard let inviteList = callRecord.inviteList as? [String] else { return }
                allUsers = inviteList
            } else if callRecord.role == .called {
                let inviter = callRecord.inviter
                allUsers.append(inviter)
            }
        case .group:
            guard let inviteList = callRecord.inviteList as? [String] else { return }
            allUsers = inviteList
            allUsers.append(callRecord.inviter)
        case .multi:
            break
        @unknown default:
            break
        }
        
        V2TIMManager.sharedInstance()?.getUsersInfo(allUsers, succ: { [weak self] infoList in
            guard let self = self else { return }
            guard let infoList = infoList else { return }
            let titleArray = infoList.map { $0.nickName ?? $0.userID }
            guard let titleArray = titleArray as? [String] else { return }
            self.titleLabelStr.value = titleArray.joined(separator: ",")
        }, fail: nil)
    }
    
    private func configTime(_ callRecord: TUICallRecords) {
        let beginTime: TimeInterval = callRecord.beginTime / 1_000
        if beginTime <= 0 {
            return
        }
        timeLabelStr = TUITool.convertDate(toStr: Date(timeIntervalSince1970: beginTime))
    }
    
    // MARK: - Cache
    private func getCacheAvatarForInviteStr(_ inviteStr: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = "group_call_avatar_\(inviteStr)"
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        let filePath = "\(cachePath)/\(cacheKey)"
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            if let data = fileManager.contents(atPath: filePath), let image = UIImage(data: data) {
                completion(image)
                return
            }
        }
        completion(nil)
    }
    
    private func cacheGroupCallAvatar(_ avatar: UIImage, inviteStr: String) {
        let cacheKey = "group_call_avatar_\(inviteStr)"
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
        let filePath = "\(cachePath)/\(cacheKey)"
        let fileManager = FileManager.default
        
        if let data = avatar.pngData() {
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
    }
}
