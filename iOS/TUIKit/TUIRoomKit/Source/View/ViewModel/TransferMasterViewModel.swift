//
//  TransferMasterViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/2/20.
//

import Foundation

protocol TransferMasterViewResponder: NSObject {
    func reloadTransferMasterTableView()
    func searchControllerChangeActive(isActive: Bool)
}

class TransferMasterViewModel: NSObject {
    var attendeeList: [UserEntity] = []
    var userId: String = ""
    weak var viewResponder: TransferMasterViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    let roomRouter: RoomRouter = RoomRouter.shared
    override init() {
        super.init()
        attendeeList = self.engineManager.store.attendeeList.filter({ [weak self] userModel in
            guard let self = self else { return true }
            return userModel.userId != self.engineManager.store.currentUser.userId
        })
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
    }
    
    func backAction() {
        RoomRouter.shared.dismissPopupViewController(viewType: .transferMasterViewType)
    }
    
    func appointMasterAction(sender: UIButton) {
        guard userId != "" else { return }
        engineManager.changeUserRole(userId: userId, role: .roomOwner) { [weak self] in
            guard let self = self else { return }
            self.engineManager.exitRoom(onSuccess: nil, onError: nil)
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.engineManager.destroyRoom(onSuccess: nil, onError: nil)
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
            debugPrint("changeUserRole:code:\(code),message:\(message)")
        }
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension TransferMasterViewModel: PopUpViewResponder {
    func updateViewOrientation(isLandscape: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: false)
        attendeeList = engineManager.store.attendeeList
        viewResponder?.reloadTransferMasterTableView()
    }
    
    func searchControllerChangeActive(isActive: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: isActive)
    }
}

extension TransferMasterViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RenewUserList:
            attendeeList = self.engineManager.store.attendeeList.filter({ [weak self] userModel in
                guard let self = self else { return true }
                return userModel.userId != self.engineManager.store.currentUser.userId
            })
            viewResponder?.reloadTransferMasterTableView()
        default: break
        }
    }
}
