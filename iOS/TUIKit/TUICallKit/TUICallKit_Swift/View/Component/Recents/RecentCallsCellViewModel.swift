//
//  RecentCallsCellViewModel.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation
import UIKit
import RTCRoomEngine
import ImSDK_Plus
import TUICore
import RTCCommon

class RecentCallsCellViewModel {
    
    var avatarImage: Observable<UIImage> = Observable(UIImage())
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
        guard var userIds = callRecord.inviteList as? [String] else { return }
        userIds.append(callRecord.inviter)
        let selfUserId = CallManager.shared.userState.selfUser.id.value
        userIds = userIds.filter { $0 != selfUserId }
        
        if (!callRecord.groupId.isEmpty || userIds.count >= 2) {
            var inviteList = callRecord.inviteList
            inviteList.insert(callRecord.inviter, at: 0)
            guard let inviteList = inviteList as? [String] else { return }
            configGroupAvatarImage(inviteList)
        } else {
            configSingleAvatarImage(callRecord)
        }
    }
    
    private func configGroupAvatarImage(_ inviteList: [String]) {
        if inviteList.isEmpty {
            avatarImage.value = TUICoreDefineConvert.getDefaultGroupAvatarImage()
            return
        }
        
        let inviteStr = inviteList.joined(separator: "#")
        
        getCacheAvatarForInviteStr(inviteStr) { [weak self] avatar in
            guard let self = self else { return }
            if let avatar = avatar {
                self.avatarImage.value = avatar
            } else {
                V2TIMManager.sharedInstance().getUsersInfo(inviteList, succ: { infoList in
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
                        self.avatarImage.value = image
                        self.cacheGroupCallAvatar(image, inviteStr: inviteStr)
                    })
                }, fail: nil)
            }
        }
    }
    
    private func configSingleAvatarImage(_ callRecord: TUICallRecords) {
        avatarImage.value = TUICoreDefineConvert.getDefaultAvatarImage()
        var useId = callRecord.inviter
        
        if callRecord.role == .call {
            guard let firstInvite = callRecord.inviteList.first as? String else { return }
            useId = firstInvite
        }
        
        if !useId.isEmpty {
            V2TIMManager.sharedInstance().getUsersInfo([useId], succ: { [weak self] infoList in
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
            resultLabelStr = TUICallKitLocalize(key: "TUICallKit.Recents.missed") ?? "Missed"
        case .incoming:
            resultLabelStr = TUICallKitLocalize(key: "TUICallKit.Recents.incoming") ?? "Incoming"
        case .outgoing:
            resultLabelStr = TUICallKitLocalize(key: "TUICallKit.Recents.outgoing") ?? "Outgoing"
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
        guard var userIds = callRecord.inviteList as? [String] else { return }
        userIds.append(callRecord.inviter)
        
        let selfUserId = CallManager.shared.userState.selfUser.id.value
        userIds = userIds.filter { $0 != selfUserId }

        titleLabelStr.value = ""
        UserManager.getUserInfosFromIM(userIDs: userIds) { [weak self] infoList in
            guard let self = self else { return }
            let titleArray = infoList.map { $0.remark.value.count > 0
                ? $0.remark.value
                : $0.nickname.value.count > 0 ? $0.nickname.value : $0.id.value }
            self.titleLabelStr.value = titleArray.joined(separator: ",")
        }
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
