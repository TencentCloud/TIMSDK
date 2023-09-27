//
//  RoomMessageView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

class RoomMessageView: UIView {
    let viewModel: RoomMessageViewModel
    private var viewArray: [UIView] = []
    let roomStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0xD1E4FD)
        return view
    }()
    let roomStatusImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    let roomStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 15)
        return label
    }()
    let roomNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 20)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .leading
        view.distribution = .equalSpacing
        view.spacing = 2
        return view
    }()
    lazy var inviteUserButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_chat_invite", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        return button
    }()
    let userNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(0x888888)
        label.textAlignment = isRTL ? .right : .left
        return label
    }()
    let enterRoomButton: UIButton = {
        let button = UIButton()
        button.setTitle(.enterMeetingText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIColor.tui_color(withHex: "147AFF").trans2Image(), for: .normal)
        button.setTitle(.alreadyEnteredMeeting, for: .selected)
        button.setTitleColor(UIColor(0x999999), for: .selected)
        button.setBackgroundImage(UIColor.tui_color(withHex: "F3F4F4").trans2Image(), for: .selected)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 15)
        return button
    }()
    let enterRoomStatusLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "PingFangSC-Regular", size: 15)
        label.textColor = UIColor(0x888888)
        label.textAlignment = .center
        return label
    }()
    init(viewModel: RoomMessageViewModel) {
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
        backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(roomStatusView)
        roomStatusView.addSubview(roomStatusImageView)
        roomStatusView.addSubview(roomStatusLabel)
        roomStatusView.addSubview(roomNameLabel)
        roomStatusView.addSubview(stackView)
        setupUserStackView()
        roomStatusView.addSubview(inviteUserButton)
        addSubview(enterRoomStatusLabel)
        addSubview(userNumberLabel)
        addSubview(enterRoomButton)
    }
    func activateConstraints() {
        roomStatusView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
        }
        roomStatusImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(12)
        }
        roomStatusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(roomStatusImageView)
            make.leading.equalTo(roomStatusImageView.snp.trailing).offset(4)
        }
        roomNameLabel.snp.makeConstraints { make in
            make.top.equalTo(roomStatusImageView.snp.bottom).offset(9)
            make.leading.equalTo(roomStatusImageView)
            make.trailing.equalToSuperview().offset(-12)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(roomNameLabel)
            make.bottom.equalToSuperview().offset(-4)
        }
        inviteUserButton.snp.makeConstraints { make in
            make.leading.equalTo(stackView.snp.trailing).offset(2)
            make.width.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-4)
        }
        userNumberLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        enterRoomButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(70)
            make.height.equalTo(27)
        }
        enterRoomStatusLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(20)
        }
    }
    func bindInteraction() {
        viewModel.viewResponder = self
        enterRoomButton.addTarget(self, action: #selector(enterRoomAction(sender:)), for: .touchUpInside)
        inviteUserButton.addTarget(self, action: #selector(inviteUserAction(sender:)), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
        addGestureRecognizer(longPressGesture)
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(0xDDDDDD).cgColor
        setupViewState()
    }
    
    @objc func enterRoomAction(sender: UIButton) {
        viewModel.enterRoomAction()
    }
    
    @objc func inviteUserAction(sender: UIButton) {
        viewModel.inviteUserAction()
    }
    
    @objc func longPressAction(sender: UIView) {
        return
    }
    
    func setupViewState() {
        roomNameLabel.text = (viewModel.message.ownerName ) + .quickMeetingText
        if viewModel.message.owner != viewModel.userId {
            inviteUserButton.isHidden = true
        } else {
            inviteUserButton.isHidden = false
        }
        switch viewModel.message.roomState {
        case .creating:
            //正在发起会议
            roomStatusImageView.image = UIImage(named: "room_is_creating", in: tuiRoomKitBundle(), compatibleWith: nil)
            roomStatusLabel.text = .meetingText
            enterRoomStatusLabel.isHidden = false
            enterRoomStatusLabel.text = .startingMeetingText + "..."
            userNumberLabel.isHidden = true
            enterRoomButton.isHidden = true
            roomStatusView.backgroundColor = UIColor(0xDCEAFD)
        case .created:
            //创建房间成功
            roomStatusImageView.image = UIImage(named: "room_created_success", in: tuiRoomKitBundle(), compatibleWith: nil)
            roomStatusLabel.text = .meetingText + "." + .inProgressText
            roomStatusLabel.textColor = UIColor(0x15B72D)
            enterRoomButton.isHidden = false
            userNumberLabel.isHidden = false
            enterRoomStatusLabel.isHidden = true
            if viewModel.message.memberCount > 1 {
                userNumberLabel.text = String(viewModel.message.memberCount) + .peopleEnteredMeetingText
            } else {
                userNumberLabel.text = .waitingMembersEnterMeetingText
            }
            roomStatusView.backgroundColor = UIColor(0xDCEAFD)
        case .destroyed:
            //房间解散
            roomStatusImageView.image = UIImage(named: "room_has_destroyed", in: tuiRoomKitBundle(), compatibleWith: nil)
            roomStatusLabel.text = .meetingText
            roomStatusLabel.textColor = UIColor(0x888888)
            enterRoomStatusLabel.isHidden = false
            enterRoomStatusLabel.text = .meetingEnded
            enterRoomButton.isHidden = true
            userNumberLabel.isHidden = true
            roomStatusView.backgroundColor = UIColor(0xDDDDDD)
            inviteUserButton.isHidden = true
        default: break
        }
    }
    
    func setupStackView() {
        if !isViewReady {
            return
        }
        setupUserStackView()
        layoutIfNeeded()
        if viewModel.message.memberCount > 1 {
            userNumberLabel.text = String(viewModel.message.memberCount) + .peopleEnteredMeetingText
        } else {
            userNumberLabel.text = .waitingMembersEnterMeetingText
        }
    }
    
    private func setupUserStackView() {
        var userNumber = 0
        viewArray.forEach { view in
            view.removeFromSuperview()
        }
        viewModel.message.userList.forEach { userDic in
            if userNumber >= 5 {
                let label = UILabel()
                label.text = "..."
                viewArray.append(label)
                stackView.addArrangedSubview(label)
                label.snp.makeConstraints { make in
                    make.height.equalTo(24)
                    make.width.equalTo(24)
                }
                return
            }
            let placeholderImage = UIImage(named: "room_default_avatar", in: tuiRoomKitBundle(), compatibleWith: nil)
            let imageView = UIImageView()
            if let userAvatar = userDic["faceUrl"] as? String {
                imageView.sd_setImage(with: URL(string: userAvatar), placeholderImage: placeholderImage)
            } else {
                imageView.image = placeholderImage
            }
            viewArray.append(imageView)
            stackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.height.equalTo(24)
                make.width.equalTo(24)
            }
            userNumber = userNumber + 1
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let viewFrame = self.frame
        let inviteViewFrame = self.inviteUserButton.frame
        if viewFrame.contains(point) && !inviteViewFrame.contains(point) {
            return enterRoomButton
        }
        return super.hitTest(point, with: event)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RoomMessageView: RoomMessageViewResponder {
    func updateStackView() {
        setupStackView()
    }
    func updateRoomStatus() {
        setupViewState()
    }
    func changeEnterRoomButton(isEnabled: Bool) {
        enterRoomButton.isEnabled = isEnabled
    }
    func updateEnteredRoom() {
        enterRoomButton.isSelected = true
    }
    func updateExitRoom() {
        enterRoomButton.isSelected = false
    }
}

private extension String {
    static var inviteMeetingText: String {
        localized("TUIRoom.invite.meeting")
    }
    static var enterMeetingText: String {
        localized("TUIRoom.enter.meeting")
    }
    static var alreadyEnteredMeeting: String {
        localized("TUIRoom.already.entered.meeting")
    }
    static var meetingText: String {
        localized("TUIRoom.meeting")
    }
    static var inProgressText: String {
        localized("TUIRoom.in.progress")
    }
    static var peopleEnteredMeetingText: String {
        localized("TUIRoom.people.entered.meeting")
    }
    static var startingMeetingText: String {
        localized("TUIRoom.starting.meeting")
    }
    static var waitingMembersEnterMeetingText: String {
        localized("TUIRoom.waiting.members.enter.meeting")
    }
    static var meetingEnded: String {
        localized("TUIRoom.meeting.ended")
    }
    static var quickMeetingText: String {
        localized("TUIRoom.quick.meeting")
    }
}
