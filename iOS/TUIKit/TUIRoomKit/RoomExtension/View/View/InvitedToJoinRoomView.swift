//
//  RoomaInviteView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/24.
//

import Foundation

class InvitedToJoinRoomView: UIView {
    let viewModel : InvitedToJoinRoomViewModel
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 30)
        label.textColor = .white
        return label
    }()
    let inviteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 15)
        label.text = .inviteMeetingText
        label.textColor = .white
        return label
    }()
    let userImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    let disagreeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    let disagreeImageView: UIImageView = {
        let image = UIImage(named: "room_hangup", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    let disagreeLabel: UILabel = {
        let label = UILabel()
        label.text = .declineText
        label.textColor = .red
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20.0)
        return label
    }()
    let agreeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    let agreeImageView: UIImageView = {
        let image = UIImage(named: "room_handsfree_on", in: tuiRoomKitBundle(), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        return imageView
    }()
    let agreeLabel: UILabel = {
        let label = UILabel()
        label.text = .agreeText
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20.0)
        return label
    }()
    
    init(viewModel: InvitedToJoinRoomViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = UIColor(0x242424)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    private func constructViewHierarchy() {
        addSubview(userNameLabel)
        addSubview(inviteLabel)
        addSubview(userImageView)
        addSubview(disagreeButton)
        disagreeButton.addSubview(disagreeImageView)
        disagreeButton.addSubview(disagreeLabel)
        addSubview(agreeButton)
        agreeButton.addSubview(agreeImageView)
        agreeButton.addSubview(agreeLabel)
    }
    private func activateConstraints() {
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
            make.trailing.equalToSuperview().offset(-130)
        }
        inviteLabel.snp.makeConstraints { make in
            make.trailing.equalTo(userNameLabel)
            make.top.equalTo(userNameLabel.snp.bottom).offset(15)
        }
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(80)
        }
        disagreeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-100)
            make.width.equalTo(80)
            make.height.equalTo(120)
            make.leading.equalToSuperview().offset(50)
        }
        disagreeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        disagreeLabel.snp.makeConstraints { make in
            make.top.equalTo(disagreeImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.bottom.equalToSuperview()
        }
        agreeButton.snp.makeConstraints { make in
            make.bottom.equalTo(disagreeButton)
            make.width.equalTo(80)
            make.height.equalTo(120)
            make.trailing.equalToSuperview().offset(-50)
        }
        agreeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        agreeLabel.snp.makeConstraints { make in
            make.top.equalTo(agreeImageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.bottom.equalToSuperview()
        }
    }
    private func bindInteraction() {
        disagreeButton.addTarget(self, action: #selector(disagreeAction(sender:)), for: .touchUpInside)
        agreeButton.addTarget(self, action: #selector(agreeAction(sender:)), for: .touchUpInside)
        viewModel.startPlay()
        setupViewState()
    }
    func setupViewState() {
        userNameLabel.text = viewModel.inviteUserName
        let placeholderImage = UIImage(named: "room_default_avatar", in: tuiRoomKitBundle(), compatibleWith: nil)
        userImageView.sd_setImage(with: URL(string: viewModel.avatarUrl), placeholderImage: placeholderImage)
    }
    @objc private func disagreeAction(sender: UIButton) {
        viewModel.disagreeAction()
    }
    @objc private func agreeAction(sender: UIButton) {
        viewModel.agreeAction()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var inviteMeetingText: String {
        localized("TUIRoom.invite.meeting")
    }
    static var declineText: String {
        localized("TUIRoom.decline")
    }
    static var agreeText: String {
        localized("TUIRoom.agree")
    }
}
