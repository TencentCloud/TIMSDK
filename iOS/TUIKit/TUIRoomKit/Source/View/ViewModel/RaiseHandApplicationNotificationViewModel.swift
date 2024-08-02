//
//  RaiseHandApplicationNotificationViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/5/16.
//

import Foundation
import RTCRoomEngine

protocol RaiseHandApplicationNotificationViewModelResponder: AnyObject {
    func showRaiseHandApplicationNotificationView(userId: String, userName: String, count: Int)
    func hideRaiseHandApplicationNotificationView()
}

class RaiseHandApplicationNotificationViewModel: NSObject {
    var delayDisappearanceTime = 5.0
    lazy var userId: String? = {
        return inviteSeatList.last?.userId
    }()
    lazy var userName: String? = {
        return inviteSeatList.last?.userName
    }()
    lazy var applicationCount: Int? = {
        return inviteSeatList.count
    }()
    weak var responder: RaiseHandApplicationNotificationViewModelResponder?
    var inviteSeatList: [RequestEntity] {
        EngineManager.shared.store.inviteSeatList
    }
    lazy var isShownRaiseHandApplicationNotificationView: Bool = {
        return getShownRequestEntity() != nil
    }()
    override init() {
        super.init()
        subscribeEngine()
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onDeletedTakeSeatRequest, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onDeletedTakeSeatRequest, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
    }
    
    private func getShownRequestEntity() -> RequestEntity? {
        let currentTime = Date().timeIntervalSince1970
        guard let lastItem = inviteSeatList.last else { return nil }
        if delayDisappearanceTime > 0, currentTime - lastItem.timestamp > delayDisappearanceTime {
            return nil
        } else {
            return lastItem
        }
    }
    
    func checkRaiseHandApplicationAction() {
        RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: 720.scale375Height(), backgroundColor: UIColor(0x22262E))
    }
    
    deinit {
        unsubscribeEngine()
    }
}

extension RaiseHandApplicationNotificationViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onRequestReceived:
            guard let request = param?["request"] as? TUIRequest else { return }
            guard request.requestAction == .takeSeat else { return }
            self.userId = request.userId
            self.userName = request.userName
            responder?.showRaiseHandApplicationNotificationView(userId: request.userId, userName: request.userName, count: inviteSeatList.count)
        case .onDeletedTakeSeatRequest:
            guard let userId = param?["userId"] as? String else { return }
            guard userId == self.userId else { return }
            let requestItem = getShownRequestEntity()
            self.userId = requestItem?.userId
            self.userName = requestItem?.userName
            if let requestItem = requestItem {
                responder?.showRaiseHandApplicationNotificationView(userId: requestItem.userId, userName: requestItem.userName, count: inviteSeatList.count)
            } else {
                responder?.hideRaiseHandApplicationNotificationView()
            }
        default: break
        }
    }
}

extension RaiseHandApplicationNotificationViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_RenewSeatList {
            guard let requestItem = getShownRequestEntity() else { return }
            responder?.showRaiseHandApplicationNotificationView(userId: requestItem.userId, userName: requestItem.userName, count: inviteSeatList.count)
        }
    }
}


