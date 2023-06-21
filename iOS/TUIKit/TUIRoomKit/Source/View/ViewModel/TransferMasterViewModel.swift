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

class TransferMasterViewModel {
    var attendeeList: [UserModel] = []
    var userId: String = ""
    weak var viewResponder: TransferMasterViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.shared
    }
    let roomRouter: RoomRouter = RoomRouter.shared
    init() {
        attendeeList = self.engineManager.store.attendeeList.filter({ [weak self] userModel in
            guard let self = self else { return true }
            return userModel.userId != self.engineManager.store.currentUser.userId
        })
    }
    
    func backAction() {
        RoomRouter.shared.dismissPopupViewController(viewType: .transferMasterViewType)
    }
    
    func appointMasterAction(sender: UIButton) {
        guard userId != "" else { return }
        engineManager.roomEngine.changeUserRole(userId: userId, role: .roomOwner) { [weak self] in
            guard let self = self else { return }
            self.closeLocalDevice()
            self.engineManager.exitRoom()
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.closeLocalDevice()
            self.engineManager.destroyRoom()
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
            debugPrint("changeUserRole:code:\(code),message:\(message)")
        }
    }
    
    private func closeLocalDevice() {
        let roomEngine = engineManager.roomEngine
        roomEngine.closeLocalCamera()
        roomEngine.closeLocalMicrophone()
        roomEngine.stopPushLocalAudio()
        roomEngine.stopPushLocalVideo()
        roomEngine.stopScreenCapture()
        roomEngine.getTRTCCloud().setLocalVideoProcessDelegete(nil, pixelFormat: ._Texture_2D, bufferType: .texture)
    }
    
    deinit {
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
