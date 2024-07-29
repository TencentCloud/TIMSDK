//
//  CallUserInfoView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class CallUserInfoView: UIView {
    
    let remoteUserListObserver = Observer()
    
    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 6.0
        if let image = TUICallKitCommon.getBundleImage(name: "default_user_icon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor.t_colorWithHexString(color: "#D5E0F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUserImageAndName()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(userHeadImageView)
        addSubview(userNameLabel)
    }
    
    func activateConstraints() {
        self.userHeadImageView.snp.makeConstraints { make in
            make.top.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 100.scaleWidth(), height: 100.scaleWidth()))
        }
        self.userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView.snp.bottom).offset(10.scaleHeight())
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(30)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserListChanged()
    }
    
    func remoteUserListChanged() {
        TUICallState.instance.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setUserImageAndName()
        })
    }
    
    // MARK: Update UI
    func setUserImageAndName() {
        let remoteUser = TUICallState.instance.remoteUserList.value.first ?? User()
        userNameLabel.text = User.getUserDisplayName(user: remoteUser)
        
        if let url = URL(string: remoteUser.avatar.value) {
            userHeadImageView.sd_setImage(with: url)
        }
    }
}
