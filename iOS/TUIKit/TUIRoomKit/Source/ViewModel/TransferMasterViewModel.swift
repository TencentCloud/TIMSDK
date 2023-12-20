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
    func makeToast(message: String)
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
            self.engineManager.exitRoom { [weak self] in
                guard let self = self else { return }
                self.roomRouter.dismissAllRoomPopupViewController()
                self.roomRouter.popToRoomEntranceViewController()
            } onError: { [weak self] code, message in
                guard let self = self else { return }
                self.viewResponder?.makeToast(message: message)
            }
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.viewResponder?.makeToast(message: message)
        }
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension TransferMasterViewModel: PopUpViewModelResponder {
    func updateViewOrientation(isLandscape: Bool) {
        viewResponder?.searchControllerChangeActive(isActive: false)
        attendeeList = engineManager.store.attendeeList.filter({ [weak self] userModel in
            guard let self = self else { return true }
            return userModel.userId != self.engineManager.store.currentUser.userId
        })
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
            attendeeList = engineManager.store.attendeeList.filter({ [weak self] userModel in
                guard let self = self else { return true }
                return userModel.userId != self.engineManager.store.currentUser.userId
            })
            viewResponder?.reloadTransferMasterTableView()
        default: break
        }
    }
}
