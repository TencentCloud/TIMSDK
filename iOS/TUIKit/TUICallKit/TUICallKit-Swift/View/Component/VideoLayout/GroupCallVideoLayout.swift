//
//  GroupCallVideoLayout.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//
import Foundation

private let kItemWidth2People = (Screen_Width - 10) / 2.0
private let kItemWidth3People = (Screen_Width - 10) / 3.0

class GroupCallVideoLayout: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let viewModel = GroupCallVideoLayoutViewModel()
    let selfCallStatusObserver = Observer()
    lazy var colleeCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let colleeCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        colleeCollectionView.delegate = self
        colleeCollectionView.dataSource = self
        colleeCollectionView.showsVerticalScrollIndicator = false
        colleeCollectionView.showsHorizontalScrollIndicator = false
        colleeCollectionView.backgroundColor = UIColor.clear
        return colleeCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.t_colorWithHexString(color: "#242424")

        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.remoteUserList.removeObserver(selfCallStatusObserver)
        
        for view in subviews {
            view.removeFromSuperview()
        }
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
        addSubview(colleeCollectionView)
    }

    func activateConstraints() {
        colleeCollectionView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(snp.top).offset(60)
            make.width.height.equalTo(Screen_Width - 10)
        }
    }

    func bindInteraction() {
        for i in 0..<9 {
            colleeCollectionView.register(GroupCallVideoCell.self, forCellWithReuseIdentifier: "GroupCallVideoCell_\(i)")
        }
    }
        
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserChanged()
    }
    
    func remoteUserChanged() {
        viewModel.remoteUserList.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.colleeCollectionView.performBatchUpdates {
                self.colleeCollectionView.reloadData()
            }
        })
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension GroupCallVideoLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.remoteUserList.value.count == 0 ? 0 : viewModel.remoteUserList.value.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCallVideoCell_\(indexPath.row)",
                                                      for: indexPath) as! GroupCallVideoCell
        if indexPath.row == 0 {
            cell.initCell(user: viewModel.selfUser.value)
        } else {
            cell.initCell(user: viewModel.remoteUserList.value[indexPath.row - 1])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.remoteUserList.value.count <= 3 {
            return CGSize(width: kItemWidth2People, height: kItemWidth2People)
        } else {
            return CGSize(width: kItemWidth3People, height: kItemWidth3People)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
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
        return  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
