//
//  InviteeAvatarListView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation

private let kItemWidth = 32.scaleWidth()
private let kSpacing = 5.scaleWidth()

class InviteeAvatarListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let remoteUserListObserver = Observer()
    let dataSource: Observable<[User]> = Observable(Array())
    
    lazy var describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor.t_colorWithHexString(color: "#D5E0F2")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.calleeTip") ?? ""
        return describeLabel
    }()
    
    lazy var calleeCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let calleeCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        calleeCollectionView.delegate = self
        calleeCollectionView.dataSource = self
        calleeCollectionView.showsVerticalScrollIndicator = false
        calleeCollectionView.showsHorizontalScrollIndicator = false
        calleeCollectionView.backgroundColor = UIColor.clear
        return calleeCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var dataList = TUICallState.instance.remoteUserList.value
        dataList.append(TUICallState.instance.selfUser.value)
        dataSource.value = removeCallUser(remoteUserList: dataList)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    func removeCallUser(remoteUserList: [User]) -> [User] {
        let userList = remoteUserList.filter { $0.callRole.value != .call }
        return userList
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        updateDescribeLabel()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(describeLabel)
        addSubview(calleeCollectionView)
    }
    
    func activateConstraints() {
        describeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(calleeCollectionView.snp.top).offset(-5.scaleWidth())
            make.centerX.equalTo(self)
            make.width.equalTo(Screen_Width)
            make.height.equalTo(20)
        }
        calleeCollectionView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(Screen_Width)
            make.height.equalTo(40)
        }
    }
    
    func bindInteraction() {
        calleeCollectionView.register(InviteeAvatarCell.self, forCellWithReuseIdentifier: "InviteeAvatarCell")
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserChanged()
    }
    
    func remoteUserChanged() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            var dataList = newValue
            dataList.append(TUICallState.instance.selfUser.value)
            self.dataSource.value = self.removeCallUser(remoteUserList: dataList)
            
            self.updateDescribeLabel()
            self.calleeCollectionView.reloadData()
            self.calleeCollectionView.layoutIfNeeded()
        })
    }
    
    func updateDescribeLabel() {
        let count = dataSource.value.count
        
        if count >= 1 {
            describeLabel.isHidden = false
        } else {
            describeLabel.isHidden = true
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension InviteeAvatarListView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteeAvatarCell", for: indexPath) as! InviteeAvatarCell
        cell.initCell(user: dataSource.value[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemWidth, height: kItemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellCount = collectionView.numberOfItems(inSection: section)
        var inset = (collectionView.bounds.size.width - ((CGFloat(cellCount)) * kItemWidth) - ((CGFloat(cellCount) - 1) * kSpacing)) * 0.5
        inset = max(inset, 0.0)
        return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: 0.0)
    }
    
}
