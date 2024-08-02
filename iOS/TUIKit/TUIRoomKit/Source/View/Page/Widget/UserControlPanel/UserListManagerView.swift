//
//  UserListManagerView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class UserListManagerView: UIView {
    var viewModel: UserListManagerViewModel
    private var isViewReady: Bool = false
    private var viewArray: [ButtonItemView] = []
    private var currentLandscape: Bool = isLandscape
    
    let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(0x22262E)
        view.layer.cornerRadius = 12
        return view
    }()
    
    let dropArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_drop_arrow", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 12.scale375Height(), left: 20.scale375(), bottom: 12.scale375Height(), right: 20.scale375())
        return button
    }()
    
    let rightArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_right_arrow", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 20.scale375Height(), left: 12.scale375(), bottom: 20.scale375Height(), right: 12.scale375())
        return button
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
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
        label.textAlignment = isRTL ? .right : .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let headView: UIView = {
        let view = UIView()
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
    
    let backBlockView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x17181F)
        view.alpha = 0.9
        return view
    }()
    
    init(viewModel: UserListManagerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        alpha = 0
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard currentLandscape != isLandscape else { return }
        setupViewOrientation(isLandscape: isLandscape)
        currentLandscape = isLandscape
    }
    
    private func constructViewHierarchy() {
        addSubview(backBlockView)
        addSubview(contentView)
        contentView.addSubview(dropArrowButton)
        contentView.addSubview(rightArrowButton)
        contentView.addSubview(scrollView)
        scrollView.addSubview(headView)
        scrollView.addSubview(stackView)
        headView.addSubview(avatarImageView)
        headView.addSubview(userLabel)
        setupStackView()
    }
    
    private func activateConstraints() {
        setupViewOrientation(isLandscape: isLandscape)
        headView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
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
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupViewOrientation(isLandscape: Bool) {
        backBlockView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.remakeConstraints { make in
            if isLandscape {
                make.height.equalToSuperview()
            } else {
                make.height.equalTo(500.scale375())
            }
            make.bottom.leading.trailing.equalToSuperview()
        }
        dropArrowButton.snp.remakeConstraints { make in
            make.height.equalTo(isLandscape ? 0 : 43.scale375())
            make.top.centerX.equalToSuperview()
        }
        rightArrowButton.snp.remakeConstraints { make in
            make.width.equalTo(isLandscape ? 27.scale375() : 0)
            make.leading.centerY.equalToSuperview()
        }
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(dropArrowButton.snp.bottom).offset(10.scale375())
            if isLandscape {
                make.leading.equalTo(rightArrowButton.snp.trailing).offset(5.scale375())
            } else {
                make.leading.equalToSuperview().offset(16.scale375())
            }
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16.scale375())
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        setupViewState()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backBlockView.addGestureRecognizer(tap)
        dropArrowButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    private func setupStackView() {
        for item in viewModel.userListManagerItems {
            let view = ButtonItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
                view.snp.makeConstraints { make in
                    make.height.equalTo(53.scale375())
                    make.width.equalToSuperview()
                }
        }
    }
    
    private func setupViewState() {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        guard let attendeeModel = viewModel.attendeeList.first(where: { $0.userId == viewModel.selectUserId }) else { return }
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
    
    func updateStackView(items:[ButtonItemData]) {
        for view in viewArray {
            view.removeFromSuperview()
        }
        viewArray.removeAll()
        for item in items {
            let view = ButtonItemView(itemData: item)
            viewArray.append(view)
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(53.scale375())
                make.width.equalToSuperview()
            }
        }
    }
    
    func show(rootView: UIView) {
        rootView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setupViewOrientation(isLandscape: isLandscape)
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: kScreenHeight)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
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
    func showAlert(title: String?, message: String?, sureTitle: String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?) {
        RoomRouter.presentAlert(title: title, message: message, sureTitle: sureTitle, declineTitle: declineTitle, sureBlock: sureBlock, declineBlock: declineBlock)
    }
    
    func updateUI(item: ButtonItemData) {
        guard let view = viewArray.first(where: { $0.itemData.buttonType == item.buttonType }) else { return }
        view.setupViewState(item: item)
    }
    
    func addStackView(item: ButtonItemData, index: Int?) {
        let view = ButtonItemView(itemData: item)
        if let index = index, viewArray.count > index + 1 {
            viewArray.insert(view, at: index)
            stackView.insertArrangedSubview(view, at: index)
        } else {
            viewArray.append(view)
            stackView.addArrangedSubview(view)
        }
        view.snp.makeConstraints { make in
            make.height.equalTo(53.scale375())
            make.width.equalToSuperview()
        }
    }
    
    func removeStackView(itemType: ButtonItemData.ButtonType) {
        let views = viewArray.filter({ view in
            view.itemData.buttonType == itemType
        })
        views.forEach { view in
            view.removeFromSuperview()
        }
        viewArray.removeAll(where: { $0.itemData.buttonType == itemType })
    }
    
    func dismissView() {
        dismiss()
    }
    
    func makeToast(text : String) {
        RoomRouter.makeToastInCenter(toast: text, duration: 0.5)
    }
    
    func setUserListManagerViewHidden(isHidden: Bool) {
        self.isHidden = true
    }
}

private extension String {
    static var meText: String {
        localized("Me")
    }
}

