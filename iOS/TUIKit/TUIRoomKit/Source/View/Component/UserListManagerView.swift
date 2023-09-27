//
//  UserListManagerView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class UserListManagerView: UIView {
    var viewModel: UserListManagerViewModel
    private var isViewReady: Bool = false
    
    let dropView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    let dropImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD5E0F2)
        label.backgroundColor = UIColor.clear
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    var viewArray: [UIView] = []
    
    let backBlockView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        return view
    }()
    
    init(viewModel: UserListManagerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        headView.roundedRect(rect: headView.bounds,
                             byRoundingCorners: [.topLeft, .topRight],
                             cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(backBlockView)
        addSubview(dropView)
        addSubview(headView)
        addSubview(stackView)
        dropView.addSubview(dropImageView)
        headView.addSubview(avatarImageView)
        headView.addSubview(userLabel)
    }
    
    func activateConstraints() {
        backBlockView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dropView.snp.makeConstraints { make in
            make.top.left.right.equalTo(backBlockView)
            make.height.equalTo(30.scale375())
        }
        dropImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12.scale375())
            make.centerX.equalToSuperview()
            make.height.equalTo(3.scale375())
            make.width.equalTo(24.scale375())
        }
        headView.snp.makeConstraints { make in
            make.top.equalTo(backBlockView).offset(10.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.height.equalTo(40.scale375())
        }
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(40.scale375())
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10.scale375())
            make.trailing.equalToSuperview()
            make.height.equalTo(22.scale375())
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headView.snp.bottom).offset(20.scale375())
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState()
    }
    
    func setupViewState() {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        guard let attendeeModel = viewModel.attendeeList.first(where: { $0.userId == viewModel.userId }) else { return }
        if let url = URL(string: attendeeModel.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if attendeeModel.userId == viewModel.currentUser.userId {
            userLabel.text = attendeeModel.userName + "(" + .meText + ")"
        } else {
            userLabel.text = attendeeModel.userName
        }
    }
    
    @objc func backBlockAction(sender: RoomInfoView) {
        viewModel.backBlockAction(sender: self)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension UserListManagerView: UserListManagerViewEventResponder {
    func updateUI(items: [ButtonItemData]) {
        setupViewState()
        viewArray.forEach { view in
            stackView.removeArrangedSubview(view)
        }
        viewArray = []
        for item in items {
            let view = ButtonItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            
            if view.itemData.buttonType == .muteMessageItemType {
                view.snp.remakeConstraints { make in
                    make.height.equalTo(60.scale375())
                    make.width.equalToSuperview()
                }
            }else {
                view.snp.makeConstraints { make in
                    make.height.equalTo(53.scale375())
                    make.width.equalToSuperview()
                }
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x17181F)
        }
    }
    
    func makeToast(text : String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
    }
    
    func showTransferredRoomOwnerAlert() {
        let alertVC = UIAlertController(title: .haveTransferredMasterText,
                                        message: nil,
                                        preferredStyle: .alert)
        let sureAction = UIAlertAction(title: .alertOkText, style: .cancel) { _ in
        }
        alertVC.addAction(sureAction)
        RoomRouter.shared.presentAlert(alertVC)
    }
    
    func setUserListManagerViewHidden(isHidden: Bool) {
        self.isHidden = true
    }
}

private extension String {
    static var meText: String {
        localized("TUIRoom.me")
    }
    static var alertOkText: String {
        localized("TUIRoom.ok")
    }
    static var haveTransferredMasterText: String {
        localized("TUIRoom.have.transferred.master")
    }
}

