//
//  VideoCallUserInfoView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class VideoCallUserInfoView: UIView {
    
    let viewModel = UserInfoViewModel()
    let selfCallStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRectZero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 5.0
        if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRectZero)
        userNameLabel.textColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 24.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    let waitingInviteLabel: UILabel = {
        let waitingInviteLabel = UILabel(frame: CGRectZero)
        waitingInviteLabel.textColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        waitingInviteLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        waitingInviteLabel.backgroundColor = UIColor.clear
        waitingInviteLabel.textAlignment = .center
        return waitingInviteLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateWaitingText()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    //MARK: UI Specification Processing
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
        self.userHeadImageView.snp.makeConstraints { make in
            make.top.right.equalTo(self)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        self.userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView.snp.top).offset(20)
            make.right.equalTo(userHeadImageView.snp.left).offset(-20)
        }
        
        self.waitingInviteLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView.snp.top).offset(60)
            make.right.equalTo(userHeadImageView.snp.left).offset(-20)
        }

    }

    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChange()
        remmoteUserListChanged()
    }
    
    func callStatusChange() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateWaitingText()
        })
    }
    
    func remmoteUserListChanged() {
        viewModel.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setUserImageAndName()
        })
    }

    // MARK: Update UI
    func setUserImageAndName() {
        let remoteUser = viewModel.remoteUserList.value.first ?? User()
        userNameLabel.text = remoteUser.nickname.value
        if let image = TUICallKitCommon.getUrlImage(url: remoteUser.avatar.value) {
            self.userHeadImageView.image = image
        }
    }

    func updateWaitingText() {
        switch viewModel.selfCallStatus.value {
            case .waiting:
                self.waitingInviteLabel.text = viewModel.getCurrentWaitingText()
                break
            case .accept:
                self.waitingInviteLabel.text = ""
                break
            case .none:
                break
            default:
                break
        }
    }
}
