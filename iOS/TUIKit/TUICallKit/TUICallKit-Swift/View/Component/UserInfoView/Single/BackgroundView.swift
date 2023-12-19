//
//  AvatarBackgroundView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/2.
//

import Foundation

class BackgroundView: UIView {
    
    let viewModel = UserInfoViewModel()
    let remoteUserListObserver = Observer()
    
    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.contentMode = .scaleAspectFill
        if let image = TUICallKitCommon.getBundleImage(name: "default_user_icon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.65
        return blurEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUserImage()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.remoteUserList.removeObserver(remoteUserListObserver)
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
        addSubview(blurEffectView)
    }
    
    func activateConstraints() {
        self.userHeadImageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        self.blurEffectView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        remoteUserListChanged()
    }
    
    func remoteUserListChanged() {
        viewModel.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setUserImage()
        })
    }
    
    // MARK: Update UI
    func setUserImage() {
        let remoteUser = viewModel.remoteUserList.value.first ?? User()
        userHeadImageView.sd_setImage(with: URL(string: remoteUser.avatar.value))
    }
}
