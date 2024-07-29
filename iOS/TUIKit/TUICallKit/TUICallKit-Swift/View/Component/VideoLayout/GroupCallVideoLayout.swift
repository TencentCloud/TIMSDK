//
//  GroupCallVideoLayout.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class GroupCallVideoLayout: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let selfCallStatusObserver = Observer()
    let isCameraOpenObserver = Observer()
    let selfUser = TUICallState.instance.selfUser.value
    
    var allUserList = [User]()
    
    lazy var calleeCollectionView = {
        let flowLayout = GroupCallVideoFlowLayout()
        let calleeCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        calleeCollectionView.delegate = self
        calleeCollectionView.dataSource = self
        calleeCollectionView.showsVerticalScrollIndicator = false
        calleeCollectionView.showsHorizontalScrollIndicator = false
        calleeCollectionView.backgroundColor = UIColor.clear
        return calleeCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        processUserList(remoteUserList: TUICallState.instance.remoteUserList.value)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.remoteUserList.removeObserver(selfCallStatusObserver)
        
        showLargeViewIndex = -1
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        showHistoryLargeView()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(calleeCollectionView)
    }
    
    func activateConstraints() {
        calleeCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func bindInteraction() {
        for i in 0..<9 {
            calleeCollectionView.register(GroupCallVideoCell.self, forCellWithReuseIdentifier: "GroupCallVideoCell_\(i)")
        }
    }
    
    // MARK: Set TUICallState showLargeViewUserId
    func setShowLargeViewUserId(userId: String) {
        TUICallState.instance.showLargeViewUserId.value = userId
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserChanged()
        isCameraOpenChanged()
    }
    
    func remoteUserChanged() {
        TUICallState.instance.remoteUserList.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.processUserList(remoteUserList: newValue)
            self.calleeCollectionView.reloadData()
        })
    }
    
    func processUserList(remoteUserList: [User]) {
        allUserList.removeAll()
        selfUser.index = 0
        allUserList.append(selfUser)
        
        for (index, value) in remoteUserList.enumerated() {
            value.index = index + 1
            allUserList.append(value)
        }
    }
    
    func isCameraOpenChanged() {
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue {
                self.showMySelfAsLargeView()
            }
        })
    }
    
    func showMySelfAsLargeView() {
        var row = -1
        for (index, element) in allUserList.enumerated() where element.id.value == selfUser.id.value {
            row = index
        }
        if row >= 0 && selfUser.id.value != TUICallState.instance.showLargeViewUserId.value {
            let indexPath = IndexPath(row: row, section: 0)
            performUpdates(indexPath: indexPath)
        }
    }
    
    func showHistoryLargeView() {
        var row = -1
        for (index, element) in allUserList.enumerated() where element.id.value == TUICallState.instance.showLargeViewUserId.value {
            row = index
        }
        if row >= 0 && row < allUserList.count {
            let indexPath = IndexPath(row: row, section: 0)
            performUpdates(indexPath: indexPath)
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension GroupCallVideoLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allUserList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCallVideoCell_\(indexPath.row)",
                                                      for: indexPath) as! GroupCallVideoCell
        cell.initCell(user: allUserList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performUpdates(indexPath: indexPath)
    }
    
    func performUpdates(indexPath: IndexPath) {
        let count = allUserList.count
        let remoteUpdates = getRemoteUpdates(indexPath: indexPath)
        
        var firstBigFlag = false
        if count >= 2 && count <= 4 && indexPath.row != showLargeViewIndex {
            firstBigFlag = true
        }
        
        showLargeViewIndex = (showLargeViewIndex == indexPath.row) ? -1 : indexPath.row
        if firstBigFlag {
            showLargeViewIndex = 0
        }
        
        setShowLargeViewUserId(userId: (showLargeViewIndex >= 0) ? allUserList[indexPath.row].id.value : " ")
        
        // Animate all other update types together.
        calleeCollectionView.cancelInteractiveMovement()
        calleeCollectionView.performBatchUpdates({
            var deletes = [Int]()
            var inserts = [(user:User, index:Int)]()
            
            for update in remoteUpdates {
                switch update {
                case let .delete(index):
                    calleeCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    deletes.append(index)
                    
                case let .insert(user, index):
                    calleeCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                    inserts.append((user, index))
                    
                case let .move(fromIndex, toIndex):
                    calleeCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                  to: IndexPath(item: toIndex, section: 0))
                    deletes.append(fromIndex)
                    inserts.append((allUserList[fromIndex], toIndex))
                }
            }
            
            for deletedIndex in deletes.sorted().reversed() {
                allUserList.remove(at: deletedIndex)
            }
            
            let sortedInserts = inserts.sorted(by: { (userA, userB) -> Bool in
                return userA.index <= userB.index
            })
            
            for insertion in sortedInserts {
                if insertion.index >= allUserList.startIndex && insertion.index <= allUserList.endIndex {
                    allUserList.insert(insertion.user, at: insertion.index)
                }
            }
        }) { [weak self] _ in
            guard let self = self else { return }
            self.calleeCollectionView.endInteractiveMovement()
        }
    }
    
    func getRemoteUpdates(indexPath: IndexPath) -> [UserUpdate] {
        let count = allUserList.count
        
        if count < 2 || count > 4 || indexPath.row >= count {
            return [UserUpdate]()
        }
        
        if indexPath.row == showLargeViewIndex {
            return [
                UserUpdate.move(0, allUserList[indexPath.row].index)
            ]
        }
        
        if count == 2 || allUserList[0].index == 0 {
            return [
                UserUpdate.move(indexPath.row, 0)
            ]
        }
        
        return [
            UserUpdate.move(0, allUserList[0].index),
            UserUpdate.move(indexPath.row, 0)
        ]
    }
}
