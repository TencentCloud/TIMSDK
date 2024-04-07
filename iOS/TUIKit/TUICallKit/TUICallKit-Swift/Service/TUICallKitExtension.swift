//
//  TUICallKitExtension.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/8/14.
//

import Foundation
import TUICore
import TUICallEngine

class TUICallKitExtension: NSObject, TUIExtensionProtocol {
    
    static let instance = TUICallKitExtension()
    var joinGroupCallViewModel = JoinInGroupCallViewModel()
    
    func launchCall(type: TUICallMediaType, groupID: String, pushVC: UINavigationController, isClassic: Bool) {
        if !groupID.isEmpty {
            var requestParam: [String: Any] = [:]
            requestParam[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID] = groupID
            requestParam[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name] =
            TUIGlobalization.getLocalizedString(forKey: "Make-a-call", bundle: TIMCommonLocalizableBundle)
            let viewControllerKey = isClassic ? TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Classic :
            TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Minimalist
            pushVC.push(viewControllerKey, param: requestParam) { [weak self] responseData in
                guard let self = self else { return }
                guard let modelList = responseData[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList]
                        as? [TUIUserModel] else { return }
                let userIDs: [String] = modelList.map { $0.userId }
                self.startCall(groupID: groupID, userIDs: userIDs, callingType: type)
            }
        }
    }
    
    func startCall(groupID: String, userIDs: [String], callingType: TUICallMediaType) {
        let selector = NSSelectorFromString("setOnlineUserOnly")
        if TUICallEngine.createInstance().responds(to: selector) {
            TUICallEngine.createInstance().perform(selector, with: 0)
        }
        
        if groupID.isEmpty {
            guard let userID = userIDs.first else { return }
            TUICallKit.createInstance().call(userId: userID, callMediaType: callingType)
        } else {
            TUICallKit.createInstance().groupCall(groupId: groupID, userIdList: userIDs, callMediaType: callingType)
        }
    }
    
    func doResponseInputViewExtension(param: [String: Any], type: TUICallMediaType, isClassic: Bool) {
        let userID = param[TUICore_TUIChatExtension_InputViewMoreItem_UserID] as? String ?? ""
        let groupId = param[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] as? String ?? ""
        let pushVC = param[TUICore_TUIChatExtension_InputViewMoreItem_PushVC] as? UINavigationController
        
        if !userID.isEmpty {
            startCall(groupID: "", userIDs: [userID], callingType: type)
        } else if !groupId.isEmpty {
            guard let pushVC = pushVC else { return }
            launchCall(type: type, groupID: groupId, pushVC: pushVC, isClassic: isClassic)
        }
    }
    
    // MARK: TUIExtensionProtocol
    func onRaiseExtension(_ extensionID: String, parentView: UIView, param: [AnyHashable : Any]?) -> Bool {
        if extensionID.isEmpty {
            return false
        }
        
        guard let groupId = param?[TUICore_TUIChatExtension_ChatViewTopArea_ChatID] as? String,
              let isGroup = param?[TUICore_TUIChatExtension_ChatViewTopArea_IsGroup], isGroup as! String == "1" else {
            return false
        }
        
        if extensionID == TUICore_TUIChatExtension_ChatViewTopArea_ClassicExtensionID ||
            extensionID == TUICore_TUIChatExtension_ChatViewTopArea_MinimalistExtensionID {
            let joinGroupCallView = JoinInGroupCallView()
            joinGroupCallViewModel.setJoinGroupCallView(joinGroupCallView)
            joinGroupCallViewModel.getGroupAttributes(groupId)
            parentView.subviews.forEach {
                if $0 is JoinInGroupCallView {
                    $0.removeFromSuperview()
                }
            }
            parentView.addSubview(joinGroupCallView)
            return true
        }
        
        return false
    }
    
    func onGetExtension(_ extensionID: String, param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        if extensionID.isEmpty {
            return nil
        }
        
        if extensionID == TUICore_TUIChatExtension_NavigationMoreItem_MinimalistExtensionID {
            return getNavigationMoreItemExtensionForMinimalistChat(param: param)
        } else if extensionID == TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID {
            return getInputViewMoreItemExtensionForClassicChat(param: param)
        } else if extensionID == TUICore_TUIContactExtension_FriendProfileActionMenu_ClassicExtensionID {
            return getFriendProfileActionMenuExtensionForClassicContact(param: param)
        } else if extensionID == TUICore_TUIContactExtension_FriendProfileActionMenu_MinimalistExtensionID {
            return getFriendProfileActionMenuExtensionForMinimalistContact(param: param)
        } else if extensionID == TUICore_TUIGroupExtension_GroupInfoCardActionMenu_MinimalistExtensionID {
            return getGroupInfoCardActionMenuExtensionForMinimalistGroup(param: param)
        } else {
            return nil
        }
    }
    
    func getNavigationMoreItemExtensionForMinimalistChat(param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let param = param else { return nil }
        
        let onClick: ([AnyHashable : Any]?, TUICallMediaType) -> Void = { [weak self] param, type in
            guard let self = self else { return }
            guard let param = param else { return }
            let userID = param[TUICore_TUIChatExtension_NavigationMoreItem_UserID] as? String ?? ""
            let groupID = param[TUICore_TUIChatExtension_NavigationMoreItem_GroupID] as? String ?? ""
            let pushVC = param[TUICore_TUIChatExtension_NavigationMoreItem_PushVC] as? UINavigationController
            
            if !userID.isEmpty {
                self.startCall(groupID: "", userIDs: [userID], callingType: type)
            } else if !groupID.isEmpty {
                guard let pushVC = pushVC else { return }
                self.launchCall(type: type, groupID: groupID, pushVC: pushVC, isClassic: false)
            }
        }
        
        var result: [TUIExtensionInfo] = []
        guard let filterVideoCall = param[TUICore_TUIChatExtension_NavigationMoreItem_FilterVideoCall] as? Bool else { return nil }
        
        if !filterVideoCall {
            let videoInfo = TUIExtensionInfo()
            videoInfo.weight = 200
            videoInfo.icon = TUICallKitCommon.getBundleImage(name: "video_call") ?? UIImage()
            videoInfo.onClicked = { param in
                onClick(param, .video)
            }
            result.append(videoInfo)
        }
        
        guard let filterAudioCall = param[TUICore_TUIChatExtension_NavigationMoreItem_FilterAudioCall] as? Bool else { return nil }
        if !filterAudioCall {
            let audioInfo = TUIExtensionInfo()
            audioInfo.weight = 100
            audioInfo.icon = TUICallKitCommon.getBundleImage(name: "audio_call") ?? UIImage()
            audioInfo.onClicked = { param in
                onClick(param, .audio)
            }
            result.append(audioInfo)
        }
        return result
    }
    
    func getInputViewMoreItemExtensionForClassicChat(param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let param = param else { return nil }
        
        var result: [TUIExtensionInfo] = []
        guard let filterVideoCall = param[TUICore_TUIChatExtension_InputViewMoreItem_FilterVideoCall] as? Bool else { return nil }
        
        if !filterVideoCall {
            let videoInfo = TUIExtensionInfo()
            videoInfo.weight = 600
            videoInfo.text = TUICoreDefineConvert.getTUIKitLocalizableString(key: "TUIKitMoreVideoCall")
            videoInfo.icon = TUICoreDefineConvert.getTUICoreBundleThemeImage(imageKey: "service_more_video_call_img",
                                                                             defaultImageName: "more_video_call")
            videoInfo.onClicked = { param in
                guard let param = param as? [String: Any] else { return }
                self.doResponseInputViewExtension(param: param, type: .video, isClassic: true)
            }
            result.append(videoInfo)
        }
        
        guard let filterAudioCall = param[TUICore_TUIChatExtension_InputViewMoreItem_FilterAudioCall] as? Bool else { return nil }
        if !filterAudioCall {
            let audioInfo = TUIExtensionInfo()
            audioInfo.weight = 500
            audioInfo.text = TUICoreDefineConvert.getTUIKitLocalizableString(key: "TUIKitMoreVoiceCall")
            audioInfo.icon = TUICoreDefineConvert.getTUICoreBundleThemeImage(imageKey: "service_more_voice_call_img",
                                                                             defaultImageName: "more_voice_call")
            audioInfo.onClicked = { param in
                guard let param = param as? [String: Any] else { return }
                self.doResponseInputViewExtension(param: param, type: .audio, isClassic: true)
            }
            result.append(audioInfo)
        }
        return result
    }
    
    func getFriendProfileActionMenuExtensionForClassicContact(param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let param = param else { return nil }
        
        var result: [TUIExtensionInfo] = []
        guard let filterVideoCall = param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall] as? Bool else { return nil }
        if !filterVideoCall {
            let videoInfo = TUIExtensionInfo()
            videoInfo.weight = 200
            videoInfo.text = TUICoreDefineConvert.getTUIKitLocalizableString(key: "TUIKitMoreVideoCall")
            videoInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let userID = param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserID] as? String else { return }
                if !userID.isEmpty {
                    self.startCall(groupID: "", userIDs: [userID], callingType: .video)
                }
            }
            result.append(videoInfo)
        }
        
        guard let filterAudioCall = param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall] as? Bool else { return nil }
        if !filterAudioCall {
            let audioInfo = TUIExtensionInfo()
            audioInfo.weight = 100
            audioInfo.text = TUICoreDefineConvert.getTUIKitLocalizableString(key: "TUIKitMoreVoiceCall")
            audioInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let userID = param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserID] as? String else { return }
                if !userID.isEmpty {
                    self.startCall(groupID: "", userIDs: [userID], callingType: .audio)
                }
            }
            result.append(audioInfo)
        }
        return result
    }
    
    func getFriendProfileActionMenuExtensionForMinimalistContact(param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let param = param else { return nil }
        
        var result: [TUIExtensionInfo] = []
        guard let filterVideoCall = param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterVideoCall] as? Bool else { return nil }
        if !filterVideoCall {
            let videoInfo = TUIExtensionInfo()
            videoInfo.weight = 100
            videoInfo.icon = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "", module: TUIThemeModule.contact_Minimalist,
                                                                     defaultImage: UIImage(named: TUICoreDefineConvert.getTUIContactImagePathMinimalist(imageName: "contact_info_video")) ?? UIImage())
            videoInfo.text = TUICoreDefineConvert.getTIMCommonLocalizableString(key: "TUIKitVideo")
            videoInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let userID = param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserID] as? String else { return }
                if !userID.isEmpty {
                    self.startCall(groupID: "", userIDs: [userID], callingType: .video)
                }
            }
            result.append(videoInfo)
        }
        
        guard let filterAudioCall = param[TUICore_TUIContactExtension_FriendProfileActionMenu_FilterAudioCall] as? Bool else { return nil }
        if !filterAudioCall {
            let audioInfo = TUIExtensionInfo()
            audioInfo.weight = 200
            audioInfo.icon = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "", module: TUIThemeModule.contact_Minimalist,
                                                                     defaultImage: UIImage(named: TUICoreDefineConvert.getTUIContactImagePathMinimalist(imageName: "contact_info_audio")) ?? UIImage())
            audioInfo.text = TUICoreDefineConvert.getTIMCommonLocalizableString(key: "TUIKitAudio")
            audioInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let userID = param[TUICore_TUIContactExtension_FriendProfileActionMenu_UserID] as? String else { return }
                if !userID.isEmpty {
                    self.startCall(groupID: "", userIDs: [userID], callingType: .audio)
                }
            }
            result.append(audioInfo)
        }
        return result
    }
    
    func getGroupInfoCardActionMenuExtensionForMinimalistGroup(param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let param = param else { return nil }
        
        var result: [TUIExtensionInfo] = []
        guard let filterVideoCall = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterVideoCall] as? Bool else { return nil }
        if !filterVideoCall {
            let videoInfo = TUIExtensionInfo()
            videoInfo.weight = 100
            videoInfo.icon = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "", module: TUIThemeModule.contact_Minimalist,
                                                                     defaultImage: UIImage(named: TUICoreDefineConvert.getTUIContactImagePathMinimalist(imageName: "contact_info_video")) ?? UIImage())
            videoInfo.text = TUICoreDefineConvert.getTIMCommonLocalizableString(key: "TUIKitVideo")
            videoInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let pushVC = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC] as? UINavigationController else { return }
                guard let groupID = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID] as? String else { return }
                if !groupID.isEmpty {
                    self.launchCall(type: .video, groupID: groupID, pushVC: pushVC, isClassic: false)
                }
            }
            result.append(videoInfo)
        }
        
        guard let filterAudioCall = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_FilterAudioCall] as? Bool else { return nil }
        if !filterAudioCall {
            let audioInfo = TUIExtensionInfo()
            audioInfo.weight = 200
            audioInfo.icon = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "", module: TUIThemeModule.contact_Minimalist,
                                                                     defaultImage: UIImage(named: TUICoreDefineConvert.getTUIContactImagePathMinimalist(imageName: "contact_info_audio")) ?? UIImage())
            audioInfo.text = TUICoreDefineConvert.getTIMCommonLocalizableString(key: "TUIKitAudio")
            audioInfo.onClicked = {[weak self] param in
                guard let self = self else { return }
                guard let pushVC = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_PushVC] as? UINavigationController else { return }
                guard let groupID = param[TUICore_TUIGroupExtension_GroupInfoCardActionMenu_GroupID] as? String else { return }
                if !groupID.isEmpty {
                    self.launchCall(type: .audio, groupID: groupID, pushVC: pushVC, isClassic: false)
                }
            }
            result.append(audioInfo)
        }
        return result
    }
    
}
