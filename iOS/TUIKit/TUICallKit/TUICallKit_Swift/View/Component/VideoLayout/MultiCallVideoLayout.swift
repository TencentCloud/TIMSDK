//
//  MultiCallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import RTCCommon

class MultiCallVideoLayout: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var userList = [User]()
    private var isViewReady: Bool = false
    
    private let callStatusObserver = Observer()
    private let remoteUserListObserver = Observer()
    
    private lazy var videoCollectionView = {
        let flowLayout = MultiCallVideoFlowLayout()
        let calleeCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        calleeCollectionView.delegate = self
        calleeCollectionView.dataSource = self
        calleeCollectionView.showsVerticalScrollIndicator = false
        calleeCollectionView.showsHorizontalScrollIndicator = false
        calleeCollectionView.backgroundColor = UIColor.clear
        return calleeCollectionView
    }()
    
    private let inviteeAvatarListView = MultiCallWaitingView(frame: .zero)
    
    // MARK: init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateUserList(remoteUserList: CallManager.shared.userState.remoteUserList.value)
        updateMultiCallWaitingView()
        registerObserver()
    }
    
    deinit {
        unregisterobserver()
    }
    
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(videoCollectionView)
        addSubview(inviteeAvatarListView)
    }
    
    func activateConstraints() {
        videoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = videoCollectionView.superview {
            NSLayoutConstraint.activate([
                videoCollectionView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                videoCollectionView.widthAnchor.constraint(equalTo: superview.widthAnchor),
                videoCollectionView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                videoCollectionView.topAnchor.constraint(equalTo: superview.topAnchor, constant: StatusBar_Height + 40.scale375Height())
            ])
        }

        inviteeAvatarListView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = inviteeAvatarListView.superview {
            NSLayoutConstraint.activate([
                inviteeAvatarListView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                inviteeAvatarListView.widthAnchor.constraint(equalTo: superview.widthAnchor),
                inviteeAvatarListView.heightAnchor.constraint(equalToConstant: 65.scale375Width()),
                inviteeAvatarListView.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
        }
    }
    
    func bindInteraction() {
        for i in 0..<9 {
            videoCollectionView.register(MultiCallVideoCell.self, forCellWithReuseIdentifier: "MultiCallVideoCell_\(i)")
        }
    }
    
    // MARK: Observer
    private func registerObserver() {
        CallManager.shared.userState.remoteUserList.addObserver(remoteUserListObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUserList(remoteUserList: newValue)
            self.videoCollectionView.reloadData()
        }
        
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .none { return }
            self.updateMultiCallWaitingView()
        }
    }
    
    private func unregisterobserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
        CallManager.shared.userState.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    // MARK: config view
    private func updateUserList(remoteUserList: [User]) {
        userList.removeAll()
        UserManager.shared.setUserViewIndex(user: CallManager.shared.userState.selfUser, index: 0)
        userList.append(CallManager.shared.userState.selfUser)
        
        for (index, value) in remoteUserList.enumerated() {
            UserManager.shared.setUserViewIndex(user: value, index: index + 1)
            userList.append(value)
        }
    }
    
    private func updateMultiCallWaitingView() {
        if CallManager.shared.viewState.callingViewType.value == .multi &&
            CallManager.shared.userState.selfUser.callRole.value == .called &&
            CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            inviteeAvatarListView.isHidden = false
            videoCollectionView.isHidden = true
        } else {
            inviteeAvatarListView.isHidden = true
            videoCollectionView.isHidden = false
        }
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiCallVideoCell_\(indexPath.row)", for: indexPath) as! MultiCallVideoCell
        cell.initCell(user: userList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCollectionView(indexPath: indexPath)
    }
    
    func updateCollectionView(indexPath: IndexPath) {
        let count = userList.count
        let remoteUpdates = getRemoteUpdates(indexPath: indexPath)
        
        var firstBigFlag = false
        if count >= 2 && count <= 4 && indexPath.row != showLargeViewIndex {
            firstBigFlag = true
        }
        
        showLargeViewIndex = (showLargeViewIndex == indexPath.row) ? -1 : indexPath.row
        if firstBigFlag {
            showLargeViewIndex = 0
        }
        
        setShowLargeViewUserId(userId: (showLargeViewIndex >= 0) ? userList[indexPath.row].id.value : "")
        
        videoCollectionView.cancelInteractiveMovement()
        videoCollectionView.performBatchUpdates({
            var deletes = [Int]()
            var inserts = [(user:User, index:Int)]()
            
            for update in remoteUpdates {
                switch update {
                case let .delete(index):
                    videoCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    deletes.append(index)
                    
                case let .insert(user, index):
                    videoCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                    inserts.append((user, index))
                    
                case let .move(fromIndex, toIndex):
                    videoCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                  to: IndexPath(item: toIndex, section: 0))
                    deletes.append(fromIndex)
                    inserts.append((userList[fromIndex], toIndex))
                }
            }
            
            for deletedIndex in deletes.sorted().reversed() {
                userList.remove(at: deletedIndex)
            }
            
            let sortedInserts = inserts.sorted(by: { (userA, userB) -> Bool in
                return userA.index <= userB.index
            })
            
            for insertion in sortedInserts {
                if insertion.index >= userList.startIndex && insertion.index <= userList.endIndex {
                    userList.insert(insertion.user, at: insertion.index)
                }
            }
        }) { [weak self] _ in
            guard let self = self else { return }
            self.videoCollectionView.endInteractiveMovement()
        }
    }
    
    func setShowLargeViewUserId(userId: String) {
        CallManager.shared.viewState.showLargeViewUserId.value = userId
    }
    
    func getRemoteUpdates(indexPath: IndexPath) -> [UserUpdate] {
        let count = userList.count
        
        if count < 2 || count > 4 || indexPath.row >= count {
            return [UserUpdate]()
        }
        
        if indexPath.row == showLargeViewIndex {
            return [
                UserUpdate.move(0, userList[indexPath.row].multiCallCellViewIndex)
            ]
        }
        
        if count == 2 || userList[0].multiCallCellViewIndex == 0 {
            return [
                UserUpdate.move(indexPath.row, 0)
            ]
        }
        
        return [
            UserUpdate.move(0, userList[0].multiCallCellViewIndex),
            UserUpdate.move(indexPath.row, 0)
        ]
    }
}

enum UserUpdate {
    case delete(Int)
    case insert(User, Int)
    case move(Int, Int)
}
