//
//  GroupCallerUserInfoView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/7.
//

import Foundation

class GroupCallerUserInfoView: UIView {
    
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
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    let waitingInviteLabel: UILabel = {
        let waitingInviteLabel = UILabel(frame: CGRect.zero)
        waitingInviteLabel.textColor = UIColor.t_colorWithHexString(color: "#8F9AB2")
        waitingInviteLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        waitingInviteLabel.backgroundColor = UIColor.clear
        waitingInviteLabel.text = TUICallKitLocalize(key: "TUICallKit.Group.inviteToGroupCall") ?? ""
        waitingInviteLabel.textAlignment = .center
        return waitingInviteLabel
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
        addSubview(waitingInviteLabel)
    }
    
    func activateConstraints() {
        userHeadImageView.snp.makeConstraints { make in
            make.top.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 100.scaleWidth(), height: 100.scaleWidth()))
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView.snp.bottom).offset(10.scaleHeight())
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(30)
        }
        waitingInviteLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(20.scaleHeight())
            make.centerX.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(20)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
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
