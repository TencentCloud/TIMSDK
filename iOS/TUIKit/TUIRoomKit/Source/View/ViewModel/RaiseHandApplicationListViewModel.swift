//
//  RaiseHandApplicationListViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

protocol RaiseHandApplicationListViewResponder: NSObject {
    func reloadApplyListView()
    func makeToast(text: String)
    func updatePlaceholderViewState(isShown: Bool)
    func updateApplyButtonState(isEnabled: Bool)
}

class RaiseHandApplicationListViewModel: NSObject {
    weak var viewResponder: RaiseHandApplicationListViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var inviteSeatList: [RequestEntity] = []
    
    var isPlaceholderViewShown: Bool {
        return inviteSeatList.isEmpty
    }
    
    var isApplyButtonEnabled: Bool {
        return !inviteSeatList.isEmpty
    }
    
    override init() {
        super.init()
        inviteSeatList = engineManager.store.inviteSeatList
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
    }
    
    func respondAllRequest(isAgree: Bool) {
        var isShownStageFullToast = false
        for requestEntity in engineManager.store.inviteSeatList {
            engineManager.responseRemoteRequest(requestEntity.requestId, agree: isAgree) { [weak self] in
                guard let self = self else { return }
                self.engineManager.store.deleteTakeSeatRequest(requestId: requestEntity.requestId)
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                guard code == .allSeatOccupied, !isShownStageFullToast else { return }
                self.viewResponder?.makeToast(text: .onStageNumberReachedLimitText)
                isShownStageFullToast = true
            }
        }
    }
    
    func respondRequest(isAgree: Bool, request: RequestEntity) {
        engineManager.responseRemoteRequest(request.requestId, agree: isAgree) { [weak self] in
            guard let self = self else { return }
            self.engineManager.store.deleteTakeSeatRequest(requestId: request.requestId)
            self.reloadApplyListView()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            guard code == .allSeatOccupied else { return }
            self.viewResponder?.makeToast(text: .onStageNumberReachedLimitText)
        }
    }
    
    func reloadApplyListView() {
        inviteSeatList = engineManager.store.inviteSeatList
        viewResponder?.updatePlaceholderViewState(isShown: isPlaceholderViewShown)
        viewResponder?.updateApplyButtonState(isEnabled: isApplyButtonEnabled)
        viewResponder?.reloadApplyListView()
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

private extension String {
    static var onStageNumberReachedLimitText: String {
        localized("The stage is full")
    }
}

