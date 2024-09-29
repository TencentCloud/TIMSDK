//
//  UserListCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/5/7.
//

import Foundation
import RTCRoomEngine
import Factory
import Combine

class UserListCell: UITableViewCell {
    var attendeeModel: UserEntity
    var viewModel: UserListViewModel
    
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
        label.textAlignment = .left
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let roleImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let roleLabel: UILabel = {
        let label = UILabel ()
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor(0x4791FF)
        return label
    }()
    
    let muteAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_unMute_audio", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .normal)
        button.setImage(UIImage(named: "room_mute_audio_red", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .selected)
        return button
    }()
    
    let muteVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_unMute_video", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .normal)
        button.setImage(UIImage(named: "room_mute_video_red", in: tuiRoomKitBundle(), compatibleWith: nil)?.checkOverturn(), for: .selected)
        return button
    }()
    
    let inviteStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x0565FA)
        button.layer.cornerRadius = 6
        button.setTitle(.inviteSeatText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.isHidden = true
        return button
    }()
    
    let callButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x6B758A)
        button.layer.cornerRadius = 6
        button.setTitle(.callText, for: .normal)
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 12)
        button.isHidden = true
        return button
    }()
    
    let callingLabel: UILabel = {
        let label = UILabel ()
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor(0xD5E0F2)
        label.text = .callingText
        label.isHidden = true
        return label
    }()
    
    let notJoiningLabel: UILabel = {
        let label = UILabel ()
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .right
        label.textColor = UIColor(0xD5E0F2)
        label.text = .notJoinNowText
        label.isHidden = true
        return label
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.3)
        return view
    }()
    
    init(attendeeModel: UserEntity ,viewModel: UserListViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "UserListCell")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(roleImageView)
        contentView.addSubview(roleLabel)
        contentView.addSubview(muteAudioButton)
        contentView.addSubview(muteVideoButton)
        contentView.addSubview(inviteStageButton)
        contentView.addSubview(downLineView)
        contentView.addSubview(callButton)
        contentView.addSubview(callingLabel)
        contentView.addSubview(notJoiningLabel)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        muteVideoButton.snp.makeConstraints { make in
            make.width.height.equalTo(20.scale375())
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
        }
        muteAudioButton.snp.makeConstraints { make in
            make.width.height.equalTo(20.scale375())
            make.trailing.equalTo(self.muteVideoButton.snp.leading).offset(-20.scale375())
            make.centerY.equalTo(self.avatarImageView)
        }
        inviteStageButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
            make.width.equalTo(80.scale375())
            make.height.equalTo(30.scale375Height())
        }
        userLabel.snp.makeConstraints { make in
            if attendeeModel.userRole == .generalUser {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(10.scale375Height())
            }
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12.scale375())
            make.width.equalTo(150.scale375())
            make.height.equalTo(22.scale375())
        }
        roleImageView.snp.makeConstraints { make in
            make.top.equalTo(userLabel.snp.bottom).offset(2.scale375Height())
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12.scale375())
            make.width.height.equalTo(14.scale375())
        }
        roleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(roleImageView)
            make.leading.equalTo(roleImageView.snp.trailing).offset(2.scale375())
            make.trailing.equalTo(81.scale375())
            make.height.equalTo(16.scale375())
        }
        callButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
            make.width.equalTo(48.scale375())
            make.height.equalTo(28.scale375Height())
        }
        callingLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.avatarImageView)
            make.width.equalTo(60.scale375())
            make.height.equalTo(28.scale375Height())
        }
        notJoiningLabel.snp.makeConstraints{ make in
            make.trailing.equalTo(callButton.snp.leading).offset(-12.scale375())
            make.centerY.equalTo(self.avatarImageView)
            make.width.equalTo(120.scale375())
            make.height.equalTo(28.scale375Height())
        }
        downLineView.snp.makeConstraints { make in
            make.leading.equalTo(userLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1.scale375())
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x17181F)
        setupViewState(item: attendeeModel)
        inviteStageButton.addTarget(self, action: #selector(inviteStageAction(sender:)), for: .touchUpInside)
        muteAudioButton.addTarget(self, action: #selector(showUserManageAction(sender:)), for: .touchUpInside)
        muteVideoButton.addTarget(self, action: #selector(showUserManageAction(sender:)), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(inviteEnterAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: UserEntity) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if item.userId == viewModel.currentUser.userId {
            userLabel.text = item.userName + "（" + .meText + "）"
        } else {
            userLabel.text = item.userName
        }
        switch item.userRole {
        case .roomOwner:
            roleImageView.image = UIImage(named: "room_role_owner", in: tuiRoomKitBundle(), compatibleWith: nil)
            roleLabel.text = .ownerText
        case .administrator:
            roleImageView.image = UIImage(named: "room_role_administrator", in: tuiRoomKitBundle(), compatibleWith: nil)
            roleLabel.text = .administratorText
        default: break
        }
        roleImageView.isHidden = item.userRole == .generalUser
        roleLabel.isHidden = item.userRole == .generalUser
        muteAudioButton.isSelected = !item.hasAudioStream
        muteVideoButton.isSelected = !item.hasVideoStream
        if viewModel.roomInfo.isSeatEnabled {
            muteAudioButton.isHidden = !attendeeModel.isOnSeat
            muteVideoButton.isHidden = !attendeeModel.isOnSeat
            if viewModel.checkSelfInviteAbility(invitee: attendeeModel) {
                inviteStageButton.isHidden = attendeeModel.isOnSeat
            } else {
                inviteStageButton.isHidden = true
            }
        }
        setupCallingViewState(item: item)
    }
    
    private func setupCallingViewState(item: UserEntity) {
        if let index = viewModel.invitationList.firstIndex(where: { $0.invitee.userId == item.userId }) {
            let invitation = viewModel.invitationList[index]
            muteAudioButton.isHidden = true
            muteVideoButton.isHidden = true
            inviteStageButton.isHidden = true
            let isPending = invitation.status == .pending
            callButton.isHidden = isPending
            callingLabel.isHidden = !isPending
            notJoiningLabel.isHidden = true
        }
    }
    
    func showNotJoiningLabel() {
        self.notJoiningLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.notJoiningLabel.isHidden = true
        }
    }
    
    @objc func inviteStageAction(sender: UIButton) {
        viewModel.userId = attendeeModel.userId
        viewModel.inviteSeatAction(sender: sender)
    }
    
    @objc func showUserManageAction(sender: UIButton) {
        viewModel.showUserManageViewAction(userId: attendeeModel.userId, userName: attendeeModel.userName)
    }
    
    @objc func inviteEnterAction(sender: UIButton) {
        self.conferenceStore.dispatch(action: ConferenceInvitationActions.inviteUsers(payload: (viewModel.roomInfo.roomId, [attendeeModel.userId])))
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.conferenceStore) private var conferenceStore
}

private extension String {
    static var inviteSeatText: String {
        localized("Invite to stage")
    }
    static var meText: String {
        localized("Me")
    }
    static var ownerText: String {
        localized("Host")
    }
    static var administratorText: String {
        localized("Administrator")
    }
    static var callText: String {
        localized("Call")
    }
    static var callingText: String {
        localized("Calling...")
    }
    static var notJoinNowText: String {
        localized("Not joining for now")
    }
}
