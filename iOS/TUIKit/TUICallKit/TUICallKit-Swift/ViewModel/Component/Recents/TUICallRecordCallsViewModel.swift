//
//  TUICallRecordCallsViewModel.swift
//  
//
//  Created by vincepzhang on 2023/8/28.
//

import Foundation
import UIKit
import TUICallEngine
import TUICore

/// 通话结果
enum TUICallRecordCallsType: Int {
    case all
    case missed
}

/// UI 风格类型
enum TUICallKitRecordCallsUIStyle: Int {
    case classic // 经典风格
    case minimalist // 简约风格
}

class TUICallRecordCallsViewModel {
    
    var dataSource: Observable<[TUICallRecordCallsCellViewModel]> = Observable(Array())
    var allDataSource: [TUICallRecordCallsCellViewModel] = []
    var missedDataSource: [TUICallRecordCallsCellViewModel] = []
    
    var recordCallsUIStyle: TUICallKitRecordCallsUIStyle = .minimalist
    var recordCallsType: TUICallRecordCallsType = .all
    
    func queryRecentCalls() {
        let filter = TUICallRecentCallsFilter()
        TUICallEngine.createInstance().queryRecentCalls(filter: filter, succ: { [weak self] callRecords in
            guard let self = self else { return }
            var viewModelList: [TUICallRecordCallsCellViewModel] = []
            callRecords.forEach { callRecord in
                let viewModel = TUICallRecordCallsCellViewModel(callRecord)
                viewModelList.append(viewModel)
            }
            self.updateDataSource(viewModelList)
        }, fail: {})
    }
    
    func updateDataSource(_ viewModelList: [TUICallRecordCallsCellViewModel]) {
        if viewModelList.isEmpty {
            return
        }
        cleanAllSource()
        allDataSource = viewModelList
        viewModelList.forEach { viewModel in
            if viewModel.callRecord.result == .missed {
                missedDataSource.append(viewModel)
            }
        }
        reloadDataSource()
    }
    
    func switchRecordCallsType(_ type: TUICallRecordCallsType) {
        recordCallsType = type
        reloadDataSource()
    }
    
    func reloadDataSource() {
        switch recordCallsType {
        case .all:
            dataSource.value = allDataSource
        case .missed:
            dataSource.value = missedDataSource
        }
    }
    
    func cleanAllSource() {
        dataSource.value.removeAll()
        allDataSource.removeAll()
        missedDataSource.removeAll()
    }
    
    func cleanSource(viewModel: TUICallRecordCallsCellViewModel) {
        allDataSource.removeAll() { $0.callRecord.callId == viewModel.callRecord.callId }
        missedDataSource.removeAll() { $0.callRecord.callId == viewModel.callRecord.callId }
    }
    
    func cleanSource(callId: String) {
        allDataSource.removeAll() { $0.callRecord.callId == callId }
        missedDataSource.removeAll() { $0.callRecord.callId == callId }
    }
    
    
    func repeatCall(_ indexPath: IndexPath) {
        let cellViewModel = dataSource.value[indexPath.row]
        
        if cellViewModel.callRecord.scene == .single {
            repeatSingleCall(cellViewModel.callRecord)
        }
    }
    
    func repeatSingleCall(_ callRecord: TUICallRecords) {
        var userId = callRecord.inviteList.first
        if callRecord.role == .called {
            userId = callRecord.inviter
        }
        
        guard let userId = userId as? String else { return }
        
        TUICallKit.createInstance().call(userId: userId, callMediaType: callRecord.mediaType)
    }
    
    func deleteAllRecordCalls() {
        var callIdList: [String] = []
        
        if recordCallsType == .all {
            callIdList = getCallIdList(allDataSource)
        } else if recordCallsType == .missed {
            callIdList = getCallIdList(missedDataSource)
        }
        
        TUICallEngine.createInstance().deleteRecordCalls(callIdList, succ: { [weak self] succList in
            guard let self = self else { return }
            
            succList.forEach { callId in
                self.cleanSource(callId: callId)
            }
            
            self.reloadDataSource()
        }, fail: {})
    }
    
    func getCallIdList(_ cellViewModelArray: [TUICallRecordCallsCellViewModel]) -> [String] {
        var callIdList: [String] = []
        
        if cellViewModelArray.isEmpty {
            return callIdList
        }
        
        cellViewModelArray.forEach { obj in
            callIdList.append(obj.callRecord.callId)
        }
        
        return callIdList
    }
    
    func deleteRecordCall(_ indexPath: IndexPath) {
        if indexPath.row < 0 || indexPath.row >= dataSource.value.count {
            return
        }
        let viewModel = dataSource.value[indexPath.row]
        
        TUICallEngine.createInstance().deleteRecordCalls([viewModel.callRecord.callId], succ: { [weak self] _ in
            guard let self = self else { return }
            self.cleanSource(viewModel: viewModel)
            self.reloadDataSource()
            
        }, fail: {})
    }
    
    func jumpUserInfoController(indexPath: IndexPath, navigationController: UINavigationController) {
        if indexPath.row < 0 || indexPath.row >= dataSource.value.count {
            return
        }
        let cellViewModel = dataSource.value[indexPath.row]
        
        let groupId = cellViewModel.callRecord.groupId
        var userId = cellViewModel.callRecord.inviter
        
        if cellViewModel.callRecord.role == .call {
            guard let firstUserId = cellViewModel.callRecord.inviteList.first as? String else { return }
            userId = firstUserId
        }
        
        if !groupId.isEmpty {
            let param: [String: Any] = [TUICore_TUIGroupObjectFactory_GetGroupInfoVC_GroupID: groupId]
            if TUICallKitRecordCallsUIStyle.classic == recordCallsUIStyle {
                navigationController.push(TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Classic, param: param, forResult: nil)
            } else {
                navigationController.push(TUICore_TUIGroupObjectFactory_GetGroupInfoVC_Minimalist, param: param, forResult: nil)
            }
        } else if !userId.isEmpty {
            getUserOrFriendProfileVCWithUserID(userId: userId) { viewController in
                navigationController.pushViewController(viewController, animated: true)
            } fail: { code, desc in
                TUITool.makeToastError(Int(code), msg: desc)
            }
        }
    }
    
    func getUserOrFriendProfileVCWithUserID(userId: String, succ: ((UIViewController) -> Void)?, fail: ((Int, String) -> Void)?) {
        let param: [String: Any] = [
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userId ?? "",
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ ?? { _ in },
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail ?? { _, _ in },
        ]
        
        if TUICallKitRecordCallsUIStyle.classic == self.recordCallsUIStyle {
            TUICore.createObject(TUICore_TUIContactObjectFactory,
                                 key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod, param: param)
        } else {
            TUICore.createObject(TUICore_TUIContactObjectFactory_Minimalist,
                                 key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod, param: param)
        }
    }
}
