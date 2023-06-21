//
//  UserListView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class UserListView: UIView {
    let viewModel: UserListViewModel
    
    let backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(0x1B1E26)
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        let image = UIImage(named: "room_back_white", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.setTitle(.videoConferenceTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 18)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        return button
    }()
    
    let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = .searchMemberText
        controller.searchBar.setBackgroundImage(UIColor(0x1B1E26).trans2Image(), for: .top, barMetrics: .default)
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        return controller
    }()
    
    let muteAllAudioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteAudioText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.setTitle(.allUnMuteAudioText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        let userRole = EngineManager.shared.store.currentUser.userRole
        let roomInfo = EngineManager.shared.store.roomInfo
        button.isHidden = (userRole != .roomOwner)
        button.isSelected = roomInfo.isMicrophoneDisableForAllUser
        return button
    }()
    
    let muteAllVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.allMuteVideoText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.setTitle(.allUnMuteVideoText, for: .selected)
        button.setTitleColor(UIColor(0xF2504B), for: .selected)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        let userRole = EngineManager.shared.store.currentUser.userRole
        let roomInfo = EngineManager.shared.store.roomInfo
        button.isHidden = (userRole != .roomOwner)
        button.isSelected = roomInfo.isCameraDisableForAllUser
        return button
    }()
    
    lazy var userListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x1B1E26)
        tableView.register(UserListCell.self, forCellReuseIdentifier: "UserListCell")
        tableView.tableHeaderView = searchController.searchBar
        return tableView
    }()
    
    lazy var userListManagerView: UserListManagerView = {
        let viewModel = UserListManagerViewModel()
        let view = UserListManagerView(viewModel: viewModel)
        view.isHidden = true
        return view
    }()
    
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x1B1E26)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(backButton)
        addSubview(userListTableView)
        addSubview(muteAllAudioButton)
        addSubview(muteAllVideoButton)
        addSubview(userListManagerView)
    }
    
    func activateConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(5)
            make.height.equalTo(20)
            make.width.equalTo(200)
        }
        userListTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.bottom.equalToSuperview()
        }
        muteAllAudioButton.snp.makeConstraints { make in
            make.trailing.equalTo(snp.centerX).offset(-10)
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(30)
        }
        muteAllVideoButton.snp.remakeConstraints { make in
            make.leading.equalTo(snp.centerX).offset(10)
            make.bottom.equalTo(muteAllAudioButton)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().offset(-30)
        }
        userListManagerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        muteAllVideoButton.addTarget(self, action: #selector(muteAllVideoAction(sender:)), for: .touchUpInside)
        muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioAction(sender:)), for: .touchUpInside)
    }
    @objc func backAction(sender: UIButton) {
        searchController.searchBar.endEditing(true)
        searchController.isActive = false
        viewModel.backAction()
    }
    
    @objc func muteAllAudioAction(sender: UIButton) {
        viewModel.muteAllAudioAction(sender: sender, view: self)
    }
    
    @objc func muteAllVideoAction(sender: UIButton) {
        viewModel.muteAllVideoAction(sender: sender, view: self)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension UserListView: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchArray = EngineManager.shared.store.attendeeList.filter({ model -> Bool in
            if let searchText = searchController.searchBar.text {
                return (model.userName == searchText)
            } else {
                return false
            }
        })
        viewModel.attendeeList = searchArray
        userListTableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.attendeeList = EngineManager.shared.store.attendeeList
        userListTableView.reloadData()
    }
}

extension UserListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.attendeeList.count
    }
}

extension UserListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = viewModel.attendeeList[indexPath.row]
        let cell = UserListCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.endEditing(true)
        let attendeeModel = viewModel.attendeeList[indexPath.row]
        viewModel.showUserManageViewAction(userId: attendeeModel.userId, view: self)
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.scale375()
    }
}

extension UserListView: UserListViewResponder {
    func searchControllerChangeActive(isActive: Bool) {
        searchController.searchBar.endEditing(!isActive)
        searchController.isActive = isActive
    }
    
    func makeToast(text: String) {
        self.makeToast(text)
    }
    
    func updateUIWhenRoomOwnerChanged(roomOwner: String) {
        let userInfo = EngineManager.shared.store.currentUser
        muteAllAudioButton.isHidden = roomOwner != userInfo.userId
        muteAllVideoButton.isHidden = roomOwner != userInfo.userId
    }
    
    func reloadUserListView() {
        userListTableView.reloadData()
    }
    
}

class UserListCell: UITableViewCell {
    var attendeeModel: UserModel
    var viewModel: UserListViewModel
    
    let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(0xD1D9EC)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    let muteAudioButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "room_mic_on", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "room_mic_off", in: tuiRoomKitBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    let muteVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "room_camera_on", in: tuiRoomKitBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "room_camera_off", in: tuiRoomKitBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    let inviteStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = UIColor(0x0565FA)
        button.setTitle(.inviteSeatText, for: .normal)
        button.setTitleColor(UIColor(0xFFFFFF), for: .normal)
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    init(attendeeModel: UserModel ,viewModel: UserListViewModel) {
        self.attendeeModel = attendeeModel
        self.viewModel = viewModel
        super.init(style: .default, reuseIdentifier: "UserListCell")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(userLabel)
        contentView.addSubview(muteAudioButton)
        contentView.addSubview(muteVideoButton)
        contentView.addSubview(inviteStageButton)
        contentView.addSubview(downLineView)
    }
    
    func activateConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        muteVideoButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        muteAudioButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalTo(self.muteVideoButton.snp.left).offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        inviteStageButton.snp.makeConstraints { make in
            make.width.equalTo(62.scale375())
            make.height.equalTo(24.scale375())
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
        }
        userLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.width.equalTo(150.scale375())
            make.height.equalTo(48)
        }
        downLineView.snp.makeConstraints { make in
            make.left.equalTo(userLabel)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.3)
        }
    }
    
    func bindInteraction() {
        backgroundColor = UIColor(0x1B1E26)
        setupViewState(item: attendeeModel)
        inviteStageButton.addTarget(self, action: #selector(inviteStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: UserModel) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if item.userId == EngineManager.shared.store.currentUser.userId {
            userLabel.text = item.userName + "(" + .meText + ")"
        } else {
            userLabel.text = item.userName
        }
        muteAudioButton.isSelected = !item.hasAudioStream
        muteVideoButton.isSelected = !item.hasVideoStream
        //判断是否显示邀请上台的按钮(房主在举手发言房间中可以邀请其他没有上台的用户)
        switch EngineManager.shared.store.roomInfo.speechMode {
        case .freeToSpeak:
            changeInviteStageButtonHidden(isHidden: true)
        case .applySpeakAfterTakingSeat:
            switch EngineManager.shared.store.currentUser.userRole {
            case .roomOwner:
                if attendeeModel.userRole != .roomOwner && !attendeeModel.isOnSeat {
                    changeInviteStageButtonHidden(isHidden: false)
                } else {
                    changeInviteStageButtonHidden(isHidden: true)
                }
            case .generalUser:
                changeInviteStageButtonHidden(isHidden: true)
            default: break
            }
        default: break
        }
    }
    
    @objc func inviteStageAction(sender: UIButton) {
        viewModel.userId = attendeeModel.userId
        viewModel.inviteSeatAction(sender: sender)
    }
    
    //是否显示邀请按钮（如果显示了邀请按钮，麦克风和摄像头按钮不会显示）
    private func changeInviteStageButtonHidden(isHidden: Bool) {
        inviteStageButton.isHidden = isHidden
        muteAudioButton.isHidden = !isHidden
        muteVideoButton.isHidden = !isHidden
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var allMuteAudioText: String {
        localized("TUIRoom.all.mute")
    }
    static var allMuteVideoText: String {
        localized("TUIRoom.all.mute.video")
    }
    static var allUnMuteAudioText: String {
        localized("TUIRoom.all.unmute")
    }
    static var allUnMuteVideoText: String {
        localized("TUIRoom.all.unmute.video")
    }
    static var memberText: String {
        localized("TUIRoom.conference.member")
    }
    static var searchMemberText: String {
        localized("TUIRoom.search.meeting.member")
    }
    static var inviteSeatText: String {
        localized("TUIRoom.invite.seat")
    }
    static var meText: String {
        localized("TUIRoom.me")
    }
    static var videoConferenceTitle: String {
        localized("TUIRoom.video.conference.title")
    }
}
