//
//  RecentCallsViewModel.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation
import UIKit
import RTCRoomEngine
import TUICore
import RTCCommon

enum RecentCallsType: Int {
    case all
    case missed
}

enum RecentCallsUIStyle: Int {
    case classic
    case minimalist
}

class RecentCallsViewModel {
    
    var dataSource: Observable<[RecentCallsCellViewModel]> = Observable(Array())
    var allDataSource: [RecentCallsCellViewModel] = []
    var missedDataSource: [RecentCallsCellViewModel] = []
    
    var recordCallsUIStyle: RecentCallsUIStyle = .minimalist
    var recordCallsType: RecentCallsType = .all
    
    typealias SuccClosureType = @convention(block) (UIViewController) -> Void
    typealias FailClosureType = @convention(block) (Int, String) -> Void
    
    func queryRecentCalls() {
        let filter = TUICallRecentCallsFilter()
        TUICallEngine.createInstance().queryRecentCalls(filter: filter, succ: { [weak self] callRecords in
            guard let self = self else { return }
            var viewModelList: [RecentCallsCellViewModel] = []
            callRecords.forEach { callRecord in
                let viewModel = RecentCallsCellViewModel(callRecord)
                viewModelList.append(viewModel)
            }
            self.updateDataSource(viewModelList)
        }, fail: {})
    }
    
    func updateDataSource(_ viewModelList: [RecentCallsCellViewModel]) {
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
    
    func switchRecordCallsType(_ type: RecentCallsType) {
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
    
    func cleanSource(viewModel: RecentCallsCellViewModel) {
        allDataSource.removeAll() { $0.callRecord.callId == viewModel.callRecord.callId }
        missedDataSource.removeAll() { $0.callRecord.callId == viewModel.callRecord.callId }
    }
    
    func cleanSource(callId: String) {
        allDataSource.removeAll() { $0.callRecord.callId == callId }
        missedDataSource.removeAll() { $0.callRecord.callId == callId }
    }
    
    func repeatCall(_ indexPath: IndexPath) {
        let callRecord = dataSource.value[indexPath.row].callRecord
        guard var userIds = callRecord.inviteList as? [String] else { return }
        userIds.append(callRecord.inviter)
        let selfUserId = CallManager.shared.userState.selfUser.id.value
        userIds = userIds.filter { $0 != selfUserId }
        
        if (callRecord.groupId.isEmpty && userIds.count <= 1) {
            repeatSingleCall(callRecord, userIds)
        }
    }
    
    func repeatSingleCall(_ callRecord: TUICallRecords, _ otherUserIds: [String]) {
        let targetUserId:String
        if callRecord.role == .called {
            guard let inviter = callRecord.inviter as? String else {
                return
            }
            targetUserId = inviter
        } else {
            guard let userid = otherUserIds.first as? String else {
                return
            }
            targetUserId = userid
        }
        
        if CallManager.shared.globalState.enableForceUseV2API {
            TUICallKit.createInstance().call(userId: targetUserId, callMediaType: callRecord.mediaType)
        } else {
            TUICallKit.createInstance().calls(userIdList: [targetUserId], callMediaType: callRecord.mediaType, params: nil) { } fail: { _, _ in }
        }
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
    
    func getCallIdList(_ cellViewModelArray: [RecentCallsCellViewModel]) -> [String] {
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
            let param: [String: Any] = [TUICore_TUIContactObjectFactory_GetGroupInfoVC_GroupID: groupId]
            if RecentCallsUIStyle.classic == recordCallsUIStyle {
                navigationController.push(TUICore_TUIContactObjectFactory_GetGroupInfoVC_Classic, param: param, forResult: nil)
            } else {
                navigationController.push(TUICore_TUIContactObjectFactory_GetGroupInfoVC_Minimalist, param: param, forResult: nil)
            }
        } else if !userId.isEmpty {
            getUserOrFriendProfileVCWithUserID(userId: userId) { viewController in
                navigationController.pushViewController(viewController, animated: true)
            } fail: { code, desc in
                Toast.showToast("error:\(Int(code)), msg: \(desc)")
            }
        }
    }
    
    func getUserOrFriendProfileVCWithUserID(userId: String, succ: @escaping SuccClosureType, fail: @escaping FailClosureType) {
        let param: NSDictionary = [
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_UserIDKey: userId,
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_SuccKey: succ,
            TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod_FailKey: fail,
        ]
        
        if RecentCallsUIStyle.classic == self.recordCallsUIStyle {
            TUICore.createObject(TUICore_TUIContactObjectFactory,
                                 key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod, param: param as? [AnyHashable : Any])
        } else {
            TUICore.createObject(TUICore_TUIContactObjectFactory_Minimalist,
                                 key: TUICore_TUIContactObjectFactory_GetUserOrFriendProfileVCMethod, param: param as? [AnyHashable : Any])
        }
    }
}
