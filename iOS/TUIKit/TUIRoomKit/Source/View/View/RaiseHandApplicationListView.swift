//
//  RaiseHandApplicationListView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class RaiseHandApplicationListView: UIView {
    let viewModel: RaiseHandApplicationListViewModel
    
    let backButton: UIButton = {
        let button = UIButton()
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
    
    let allAgreeButton : UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.agreeAllText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    let inviteMemberButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(.inviteMembersText, for: .normal)
        button.setTitleColor(UIColor(0xADB6CC), for: .normal)
        button.backgroundColor = UIColor(0x292D38)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    lazy var applyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(0x1B1E26)
        tableView.register(UserListCell.self, forCellReuseIdentifier: "RaiseHandCell")
        tableView.tableHeaderView = searchController.searchBar
        return tableView
    }()
    
    init(viewModel: RaiseHandApplicationListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        backgroundColor = UIColor(0x1B1E26)
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(backButton)
        addSubview(applyTableView)
        addSubview(allAgreeButton)
        addSubview(inviteMemberButton)
    }
    
    func activateConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(20)
            make.width.equalTo(200)
        }
        applyTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.bottom.equalToSuperview()
        }
        allAgreeButton.snp.makeConstraints { make in
            make.trailing.equalTo(snp.centerX).offset(-10)
            make.bottom.equalToSuperview().offset(-40 - kDeviceSafeBottomHeight)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(30)
        }
        inviteMemberButton.snp.remakeConstraints { make in
            make.leading.equalTo(snp.centerX).offset(10)
            make.bottom.equalTo(allAgreeButton)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().offset(-30)
        }
    }
    
    func bindInteraction() {
        viewModel.viewResponder = self
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        setupViewState()
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        allAgreeButton.addTarget(self, action: #selector(allAgreeStageAction(sender:)), for: .touchUpInside)
        inviteMemberButton.addTarget(self, action: #selector(inviteMemberAction(sender:)), for: .touchUpInside)
    }
    
    @objc func backAction(sender: UIButton) {
        searchController.searchBar.endEditing(true)
        searchController.isActive = false
        viewModel.backAction()
    }
    
    @objc func allAgreeStageAction(sender: UIButton) {
        viewModel.allAgreeStageAction(sender: sender, view: self)
    }
    
    @objc func inviteMemberAction(sender: UIButton) {
        viewModel.inviteMemberAction(sender: sender, view: self)
    }
    
    private func setupViewState() {
        let userRole = viewModel.engineManager.store.currentUser.userRole
        let roomInfo = viewModel.engineManager.store.roomInfo
        allAgreeButton.isHidden = (userRole != .roomOwner)
        allAgreeButton.isSelected = roomInfo.isMicrophoneDisableForAllUser
        inviteMemberButton.isHidden = (userRole != .roomOwner)
        inviteMemberButton.isSelected = roomInfo.isCameraDisableForAllUser
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension RaiseHandApplicationListView: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchArray = viewModel.engineManager.store.inviteSeatList.filter({ model -> Bool in
            if let searchText = searchController.searchBar.text {
                return (model.userName == searchText)
            } else {
                return false
            }
        })
        viewModel.inviteSeatList = searchArray
        applyTableView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.inviteSeatList = viewModel.engineManager.store.inviteSeatList
        applyTableView.reloadData()
    }
}

extension RaiseHandApplicationListView: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inviteSeatList.count
    }
}

extension RaiseHandApplicationListView: UITableViewDelegate {
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let attendeeModel = viewModel.inviteSeatList[indexPath.row]
        let cell = ApplyTableCell(attendeeModel: attendeeModel, viewModel: viewModel)
        cell.selectionStyle = .none
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.endEditing(true)
    }
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.scale375()
    }
}

extension RaiseHandApplicationListView: RaiseHandApplicationListViewResponder {
    func searchControllerChangeActive(isActive: Bool) {
        searchController.searchBar.endEditing(!isActive)
        searchController.isActive = isActive
    }
    
    func reloadApplyListView() {
        applyTableView.reloadData()
    }
}

class ApplyTableCell: UITableViewCell {
    let attendeeModel: UserModel
    let viewModel: RaiseHandApplicationListViewModel
    
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
    
    let agreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(0x0565FA)
        button.setTitle(.agreeSeatText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    let disagreeStageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        button.setTitle(.disagreeSeatText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x2A2D38)
        return view
    }()
    
    init(attendeeModel: UserModel ,viewModel: RaiseHandApplicationListViewModel) {
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
        contentView.addSubview(agreeStageButton)
        contentView.addSubview(disagreeStageButton)
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
        disagreeStageButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(self.avatarImageView)
            make.width.height.equalTo(80.scale375())
            make.height.equalTo(24.scale375())
        }
        agreeStageButton.snp.makeConstraints { make in
            make.right.equalTo(disagreeStageButton.snp.left).offset(-5)
            make.centerY.equalTo(disagreeStageButton)
            make.width.height.equalTo(80.scale375())
            make.height.equalTo(24.scale375())
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
        agreeStageButton.addTarget(self, action: #selector(agreeStageAction(sender:)), for: .touchUpInside)
        disagreeStageButton.addTarget(self, action: #selector(disagreeStageAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: UserModel) {
        let placeholder = UIImage(named: "room_default_user", in: tuiRoomKitBundle(), compatibleWith: nil)
        if let url = URL(string: item.avatarUrl) {
            avatarImageView.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        if item.userRole == .roomOwner {
            userLabel.text = item.userName + "(" + .meText + ")"
        } else {
            userLabel.text = item.userName
        }
        muteAudioButton.isSelected = !item.hasAudioStream
        muteVideoButton.isSelected = !item.hasVideoStream
        if item.isOnSeat {
            agreeStageButton.isHidden = true
            disagreeStageButton.isHidden = true
            muteAudioButton.isHidden = false
            muteVideoButton.isHidden = false
        } else {
            agreeStageButton.isHidden = false
            disagreeStageButton.isHidden = false
            muteAudioButton.isHidden = true
            muteVideoButton.isHidden = true
        }
    }
    
    @objc func agreeStageAction(sender: UIButton) {
        viewModel.agreeStageAction(sender: sender, isAgree: true, userId: attendeeModel.userId)
    }
    
    @objc func disagreeStageAction(sender: UIButton) {
        viewModel.agreeStageAction(sender: sender, isAgree: false, userId: attendeeModel.userId)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var raiseHandApplyText: String {
        localized("TUIRoom.raise.hand.apply")
    }
    static var searchMemberText: String {
        localized("TUIRoom.search.meeting.member")
    }
    static var agreeAllText: String {
        localized("TUIRoom.agree.all")
    }
    static var inviteMembersText: String {
        localized("TUIRoom.invite.members")
    }
    static var agreeSeatText: String {
        localized("TUIRoom.agree.seat")
    }
    static var disagreeSeatText: String {
        localized("TUIRoom.disagree.seat")
    }
    static var meText: String {
        localized("TUIRoom.me")
    }
    static var videoConferenceTitle: String {
        localized("TUIRoom.video.conference.title")
    }
}
