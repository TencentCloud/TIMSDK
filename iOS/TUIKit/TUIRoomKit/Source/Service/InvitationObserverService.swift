//
//  InvitationObserverService.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/23.
//

import Foundation
import RTCRoomEngine
import Factory

class InvitationObserverService: NSObject {
    static let shared = InvitationObserverService()
    private var invitationWindow: UIWindow?
    
    private override init() {
    }
    
    func showInvitationWindow(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
        DispatchQueue.main.async {
            let invitationViewController = ConferenceInvitationViewController(roomInfo: roomInfo, invitation: invitation)
            self.invitationWindow = UIWindow()
            self.invitationWindow?.windowLevel = .alert + 1
            self.invitationWindow?.rootViewController = invitationViewController
            self.invitationWindow?.isHidden = false
            self.invitationWindow?.t_makeKeyAndVisible()
        }
    }

    func dismissInvitationWindow() {
        DispatchQueue.main.async {
            self.invitationWindow?.isHidden = true
            self.invitationWindow = nil
        }
    }
}

extension InvitationObserverService: TUIConferenceInvitationObserver {
    func onReceiveInvitation(roomInfo: TUIRoomInfo, invitation: TUIInvitation, extensionInfo: String) {
        let store = Container.shared.conferenceStore()
        store.dispatch(action: ConferenceInvitationActions.onReceiveInvitation(payload: (roomInfo, invitation)))
    }

    func onInvitationHandledByOtherDevice(roomInfo: TUIRoomInfo, accepted: Bool) {
    }

    func onInvitationCancelled(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
    }

    func onInvitationAccepted(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
    }

    func onInvitationRejected(roomInfo: TUIRoomInfo, invitation: TUIInvitation, reason: TUIInvitationRejectedReason) {
    }

    func onInvitationTimeout(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
    }

    func onInvitationRevokedByAdmin(roomInfo: TUIRoomInfo, invitation: TUIInvitation, admin: TUIUserInfo) {
    }

    func onInvitationAdded(roomId: String, invitation: TUIInvitation) {
    }

    func onInvitationRemoved(roomId: String, invitation: TUIInvitation) {
    }

    func onInvitationStatusChanged(roomId: String, invitation: TUIInvitation) {
    }
}

extension UIWindow {
    public func t_makeKeyAndVisible() {
        if #available(iOS 13.0, *) {
            for windowScene in UIApplication.shared.connectedScenes {
                if windowScene.activationState == UIScene.ActivationState.foregroundActive ||
                    windowScene.activationState == UIScene.ActivationState.background {
                    self.windowScene = windowScene as? UIWindowScene
                    break
                }
            }
        }
        self.makeKeyAndVisible()
    }
}
