//
//  RaiseHandApplicationListViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

protocol RaiseHandApplicationListViewResponder: NSObject {
    func reloadApplyListView()
    func searchControllerChangeActive(isActive: Bool)
    func makeToast(text: String)
}

class RaiseHandApplicationListViewModel: NSObject {
    weak var viewResponder: RaiseHandApplicationListViewResponder? = nil
    let engineManager: EngineManager = EngineManager.createInstance()
    var roomInfo: TUIRoomInfo {
        EngineManager.createInstance().store.roomInfo
    }
    var inviteSeatList: [UserEntity] = []
    
    override init() {
        super.init()
        inviteSeatList = engineManager.store.inviteSeatList
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
    }
    
    func allAgreeStageAction(sender: UIButton, view: RaiseHandApplicationListView) {
        for userInfo in engineManager.store.inviteSeatList {
            guard let requestId = engineManager.store.inviteSeatMap[userInfo.userId] else { continue }
            engineManager.responseRemoteRequest(requestId, agree: true) { [weak self] in
                guard let self = self else { return }
                self.engineManager.deleteInviteSeatUser(userInfo.userId)
                self.reloadApplyListView()
            } onError: { _, _ in
                debugPrint("")
            }
        }
    }
    
    func inviteMemberAction(sender: UIButton, view: RaiseHandApplicationListView) {
        RoomRouter.shared.dismissPopupViewController(viewType: .raiseHandApplicationListViewType)
        RoomRouter.shared.presentPopUpViewController(viewType: .userListViewType, height: 720.scale375Height())
    }
    
    func agreeStageAction(sender: UIButton, isAgree: Bool, userId: String) {
        guard let requestId = engineManager.store.inviteSeatMap[userId] else { return }
        engineManager.responseRemoteRequest(requestId, agree: isAgree) { [weak self] in
            guard let self = self else { return }
            self.engineManager.deleteInviteSeatUser(userId)
            self.reloadApplyListView()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            guard code == .allSeatOccupied else { return }
            self.viewResponder?.makeToast(text: .onStageNumberReachedLimitText)
        }
    }
    
    func reloadApplyListView() {
        inviteSeatList = engineManager.store.inviteSeatList
        viewResponder?.reloadApplyListView()
    }
    
    func backAction() {
        RoomRouter.shared.dismissPopupViewController(viewType: .raiseHandApplicationListViewType)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension RaiseHandApplicationListViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_RenewSeatList {
            self.reloadApplyListView()
        }
    }
}

extension RaiseHandApplicationListViewModel: PopUpViewModelResponder {
    func updateViewOrientation(isLandscape: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: false)
        inviteSeatList = engineManager.store.inviteSeatList
        viewResponder?.reloadApplyListView()
    }
    
    func searchControllerChangeActive(isActive: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: isActive)
    }
}

private extension String {
    static var onStageNumberReachedLimitText: String {
        localized("TUIRoom.on.stage.number.reached.limit")
    }
}

