//
//  InviteeAvatarListViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation

class InviteeAvatarListViewModel {
    
    let remoteUserListObserver = Observer()
    
    let dataSource: Observable<[User]> = Observable(Array())
    
    init() {
        var dataList = TUICallState.instance.remoteUserList.value
        dataList.append(TUICallState.instance.selfUser.value)
        dataSource.value = removeCallUser(remoteUserList: dataList)
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func removeCallUser(remoteUserList: [User]) -> [User] {
        let userList = remoteUserList.filter { $0.callRole.value != .call }
        return userList
    }
    
    func registerObserve() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            var dataList = newValue
            dataList.append(TUICallState.instance.selfUser.value)
            self.dataSource.value = self.removeCallUser(remoteUserList: dataList)
        })
    }
    
}
