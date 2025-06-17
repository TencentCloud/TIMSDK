//
//  InviteeAvatarListView.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation
import RTCCommon

private let kItemWidth = 32.scale375Width()
private let kSpacing = 5.scale375Width()

class MultiCallWaitingView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let remoteUserListObserver = Observer()
    let dataSource: Observable<[User]> = Observable(Array())
    
    private let callerHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 6.0
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userHeadImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        }
        return userHeadImageView
    }()
    private let callerNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor(hex: "#D5E0F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userNameLabel.text = UserManager.getUserDisplayName(user: user)
        }
        return userNameLabel
    }()

    private let describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(hex: "#D5E0F2")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.calleeTip") ?? ""
        return describeLabel
    }()
    private lazy var calleeCollectionView = {
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
        var dataList = CallManager.shared.userState.remoteUserList.value
        dataList.append(CallManager.shared.userState.selfUser)
        dataSource.value = removeCallUser(remoteUserList: dataList)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CallManager.shared.userState.remoteUserList.removeObserver(remoteUserListObserver)
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
        addSubview(callerHeadImageView)
        addSubview(callerNameLabel)
    }
    
    func activateConstraints() {
        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            describeLabel.bottomAnchor.constraint(equalTo: calleeCollectionView.topAnchor, constant: -5.scale375Width()),
            describeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            describeLabel.widthAnchor.constraint(equalToConstant: Screen_Width),
            describeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])

        calleeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calleeCollectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            calleeCollectionView.widthAnchor.constraint(equalToConstant: Screen_Width),
            calleeCollectionView.heightAnchor.constraint(equalToConstant: 40)
        ])

        callerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            callerNameLabel.bottomAnchor.constraint(equalTo: describeLabel.topAnchor, constant: -20.scale375Height()),
            callerNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            callerNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        callerHeadImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            callerHeadImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            callerHeadImageView.bottomAnchor.constraint(equalTo: callerNameLabel.topAnchor, constant: -10.scale375Height()),
            callerHeadImageView.widthAnchor.constraint(equalToConstant: 100.scale375Width()),
            callerHeadImageView.heightAnchor.constraint(equalToConstant: 100.scale375Width())
        ])
    }
    
    func bindInteraction() {
        calleeCollectionView.register(MultiCallWaitingViewCell.self, forCellWithReuseIdentifier: "MultiCallWaitingViewCell")
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserChanged()
    }
    
    func remoteUserChanged() {
        CallManager.shared.userState.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            var dataList = newValue
            dataList.append(CallManager.shared.userState.selfUser)
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
extension MultiCallWaitingView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiCallWaitingViewCell", for: indexPath) as! MultiCallWaitingViewCell
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
