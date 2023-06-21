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
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xADB6CC)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 32)
        label.numberOfLines = 1
        return label
    }()
    
    let headView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
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
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    var viewArray: [UIView] = []
    
    let backBlockView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        view.backgroundColor = .black
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
        addSubview(stackView)
        addSubview(headView)
        addSubview(bottomView)
        headView.addSubview(avatarImageView)
        headView.addSubview(userLabel)
    }
    
    func activateConstraints() {
        backBlockView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        headView.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(60.scale375())
        }
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.width.height.equalTo(36.scale375())
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatarImageView.snp.right).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(32.scale375())
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backBlockAction(sender:)))
        backBlockView.addGestureRecognizer(tap)
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
            view.snp.makeConstraints { make in
                make.height.equalTo(40.scale375())
                make.width.equalToSuperview()
            }
            view.backgroundColor = item.backgroundColor ?? UIColor(0x2A2D38)
        }
    }
    func makeToast(text : String) {
        RoomRouter.makeToast(toast: text)
    }
}

private extension String {
    static var meText: String {
        localized("TUIRoom.me")
    }
}

