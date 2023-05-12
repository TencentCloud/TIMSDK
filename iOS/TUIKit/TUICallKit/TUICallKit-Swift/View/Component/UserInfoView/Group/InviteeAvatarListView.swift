//
//  InviteeAvatarListView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation

private let kItemWidth = 32.0
private let kSpacing = 5.0

class InviteeAvatarListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let viewModel = InviteeAvatarListViewModel()
    let remoteUserListObserver = Observer()
    lazy var calleeCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let calleeCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        calleeCollectionView.delegate = self
        calleeCollectionView.dataSource = self
        calleeCollectionView.showsVerticalScrollIndicator = false
        calleeCollectionView.showsHorizontalScrollIndicator = false
        calleeCollectionView.backgroundColor = UIColor.clear
        return calleeCollectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(calleeCollectionView)
    }
    
    func activateConstraints() {
        calleeCollectionView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(Screen_Width)
            make.height.equalTo(40)
        }
    }
    
    func bindInteraction() {
        for i in 0 ..< 8 {
            calleeCollectionView.register(InviteeAvatarCell.self, forCellWithReuseIdentifier: "InviteeAvatarCell_\(i)")
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserChanged()
    }
    
    func remoteUserChanged() {
        viewModel.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.calleeCollectionView.reloadData()
            self.calleeCollectionView.layoutIfNeeded()
        })
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension InviteeAvatarListView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.remoteUserList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteeAvatarCell_\(indexPath.row)", for: indexPath) as! InviteeAvatarCell
        var model: User
        if indexPath.row == 0 {
            model = viewModel.selfUser.value
        } else {
            model = viewModel.remoteUserList.value[indexPath.row]
        }
        cell.initCell(user: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kItemWidth, height: kItemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let CellCount = viewModel.remoteUserList.value.count
        let CellSpacing = CGFloat(1.0)
        let totalCellWidth = kItemWidth * CGFloat(CellCount)
        let totalSpacingWidth = CellSpacing * CGFloat(CellCount - 1)
        let leftInset = (Screen_Width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
